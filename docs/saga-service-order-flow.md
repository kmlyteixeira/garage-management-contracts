# Saga de ordem de serviço

Este documento descreve o fluxo distribuído completo entre o **OS Service**,
**Billing Service** e **Execution Service**. O OS Service atua como
orquestrador da Saga: inicia o processo, acompanha as respostas assíncronas e
aplica as compensações quando uma etapa falha.

## Visão geral

```mermaid
sequenceDiagram
    autonumber
    actor Cliente
    participant OS as OS Service<br/>(Orquestrador)
    participant Outbox as Outbox<br/>(PostgreSQL OS)
    participant MQ as RabbitMQ<br/>garage.events
    participant Billing as Billing Service
    participant Payment as Mercado Pago
    participant Execution as Execution Service
    participant Mongo as MongoDB<br/>(Execução)

    Cliente->>OS: POST /service-orders
    OS->>OS: Valida cliente, veículo e itens
    OS->>OS: Persiste OS como PendingBilling
    OS->>Outbox: ServiceOrderOpened
    OS->>Outbox: QuoteRequested
    Outbox->>MQ: Publica eventos pendentes

    MQ-->>Billing: ServiceOrderOpened / QuoteRequested
    Billing->>Billing: Calcula orçamento
    Billing->>Billing: Valida catálogo e estoque
    Billing->>Billing: Reserva estoque
    Billing->>MQ: QuoteApproved ou QuoteRejected

    alt Orçamento rejeitado ou falha de validação
        MQ-->>OS: QuoteRejected
        OS->>OS: Atualiza OS para BillingFailed/Canceled
        OS->>MQ: SagaCompensationRequested
        MQ-->>Billing: Solicita liberação de estoque
        Billing->>Billing: Libera estoque reservado
    else Orçamento aprovado
        MQ-->>OS: QuoteApproved
        OS->>OS: Atualiza OS para AwaitingPayment
        Cliente->>Billing: POST /payments
        Billing->>Payment: Cria pagamento
        Payment-->>Billing: Aprovado ou rejeitado
        Billing->>MQ: PaymentApproved ou PaymentRejected

        alt Pagamento rejeitado
            MQ-->>OS: PaymentRejected
            OS->>OS: Atualiza OS para PaymentFailed
            OS->>MQ: SagaCompensationRequested
            MQ-->>Billing: Solicita liberação de estoque
            Billing->>Billing: Libera estoque reservado
        else Pagamento aprovado
            MQ-->>OS: PaymentApproved
            OS->>OS: Atualiza OS para PendingExecution
            OS->>MQ: ExecutionRequested
            MQ-->>Execution: ExecutionRequested
            Execution->>Mongo: Persiste execução como Queued
            Execution->>Execution: Diagnóstico e reparo
            Execution->>Mongo: Atualiza execução para Completed
            Execution->>MQ: ExecutionCompleted
            MQ-->>OS: ExecutionCompleted
            OS->>OS: Atualiza OS para Finished
            OS-->>Cliente: Fluxo concluído
        end
    end
```

## Fluxo resumido por etapa

| Etapa | Serviço responsável | Ação | Evento principal |
|---|---|---|---|
| 1 | OS Service | Valida cliente, veículo e itens e cria a OS | `ServiceOrderOpened` |
| 2 | OS Service | Solicita a formação do orçamento | `QuoteRequested` |
| 3 | Billing Service | Calcula o valor, valida catálogo e reserva estoque | `QuoteApproved` ou `QuoteRejected` |
| 4 | Billing Service | Processa o pagamento externo | `PaymentApproved` ou `PaymentRejected` |
| 5 | OS Service | Solicita o início da execução após pagamento aprovado | `ExecutionRequested` |
| 6 | Execution Service | Executa diagnóstico e reparo | `ExecutionCompleted` |
| 7 | OS Service | Finaliza o ciclo da ordem de serviço | atualização para `Finished` |

## Fluxo de sucesso

```mermaid
flowchart LR
    A[Cliente abre OS] --> B[OS Service]
    B --> C[ServiceOrderOpened]
    C --> D[Billing Service]
    D --> E[Calcula orçamento]
    E --> F[Reserva estoque]
    F --> G[QuoteApproved]
    G --> H[Pagamento]
    H --> I[PaymentApproved]
    I --> J[ExecutionRequested]
    J --> K[Execution Service]
    K --> L[Queued]
    L --> M[InDiagnosis]
    M --> N[InRepair]
    N --> O[Completed]
    O --> P[ExecutionCompleted]
    P --> Q[OS Service: Finished]
```

## Fluxo de compensação

Uma Saga não desfaz uma transação distribuída com rollback global. Cada serviço
desfaz somente o efeito local que já confirmou.

```mermaid
flowchart TD
    A[Etapa da Saga falha] --> B{Onde ocorreu a falha?}
    B -->|Orçamento| C[QuoteRejected]
    B -->|Pagamento| D[PaymentRejected]
    B -->|Execução| E[SagaCompensationRequested]
    C --> F[OS Service marca BillingFailed/Canceled]
    D --> G[OS Service marca PaymentFailed]
    E --> H[OS Service interrompe o avanço da OS]
    F --> I[Billing Service libera estoque reservado]
    G --> I
    H --> I
    I --> J[Evento processado com correlationId]
```

## Envelope dos eventos

Todos os eventos devem usar o schema versionado
[`events/service-order-events.v1.json`](../events/service-order-events.v1.json)
e carregar, no mínimo:

- `eventId`: identificador único do evento;
- `eventType`: tipo da transição;
- `eventVersion`: versão do contrato;
- `correlationId`: identificador comum de toda a Saga;
- `causationId`: evento ou comando que causou a mensagem atual;
- `occurredAt`: instante UTC da publicação;
- `serviceOrderId`: ordem de serviço relacionada;
- `payload`: dados específicos do evento.

O `correlationId` permite acompanhar a Saga ponta a ponta nos logs, traces e
mensagens RabbitMQ. O `causationId` permite reconstruir a sequência causal
quando há retries ou compensações.

## Persistência e confiabilidade

- O OS Service grava eventos de saída na Outbox antes de confirmar a operação
  local.
- Um publicador da Outbox envia as mensagens pendentes para a exchange
  `garage.events`.
- O RabbitMQ distribui os eventos por tipo para os serviços interessados.
- O Billing Service mantém catálogo, orçamento e estoque no PostgreSQL próprio.
- O Execution Service mantém o estado da execução no MongoDB próprio.
- Falhas de uma etapa devem gerar evento de rejeição ou compensação, nunca uma
  confirmação falsa.
- Consumidores devem ser idempotentes usando `eventId` antes de confirmar a
  mensagem.

## Estados funcionais esperados

```mermaid
stateDiagram-v2
    [*] --> PendingBilling: OS criada
    PendingBilling --> PendingApproval: orçamento calculado
    PendingBilling --> BillingFailed: orçamento rejeitado
    PendingApproval --> AwaitingPayment: orçamento aprovado
    PendingApproval --> BillingFailed: orçamento rejeitado
    AwaitingPayment --> PendingExecution: pagamento aprovado
    AwaitingPayment --> PaymentFailed: pagamento rejeitado
    PendingExecution --> Finished: execução concluída
    Finished --> Delivered: veículo entregue
    Delivered --> Closed: OS encerrada
    BillingFailed --> Canceled: compensação/cancelamento
    PaymentFailed --> Canceled: compensação/cancelamento
    PendingExecution --> Canceled: falha ou cancelamento
    Closed --> [*]
    Canceled --> [*]
```
