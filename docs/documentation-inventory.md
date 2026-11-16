# Classificação da documentação legada

Este inventário registra quais documentos do `api-dotnet` foram trazidos para
`contracts` e quais devem permanecer em outros repositórios.

## Documentos trazidos

| Documento de origem | Destino | Motivo |
|---|---|---|
| `docs/architecture/glossary/ubiquitous-language.md` | `docs/ubiquitous-language.md` | Vocabulário compartilhado entre contratos e bounded contexts. |
| `docs/acceptance/service-order-flow.feature` | `docs/acceptance/service-order-flow.feature` | Cenários de aceitação do fluxo distribuído e da compensação. |
| Parte de `docs/architecture/fase4-microservices.md` | `docs/saga-service-order-flow.md` | O fluxo da Saga, eventos e responsabilidades já foram consolidado no documento da Saga. |

## Documentos distribuídos

| Origem | Destino canônico |
|---|---|
| `architecture/adr/001`, `002`, `006`, `008`, `009`, `010`, `011`, `012` | `garage-management-infra/docs/architecture/adr` |
| `architecture/decision-log.md` | `garage-management-infra/docs/architecture` |
| `architecture/deploy/DiagramaArquiteturaFluxoDeploy.MD` | `garage-management-infra/docs/architecture/deploy` |
| `architecture/target-architecture.md` | `garage-management-infra/docs/architecture` |
| `architecture/rfc/001`, `004`, `005` | `garage-management-infra/docs/architecture/rfc` |
| `observability/README.md` | `garage-management-infra/docs/observability` |
| `architecture/adr/003` | `garage-management-database/docs/architecture/adr` |
| `architecture/rfc/002` | `garage-management-database/docs/architecture/rfc` |
| `architecture/adr/004`, `005` | `garage-management-lambda/docs/architecture/adr` |
| `architecture/rfc/003` | `garage-management-lambda/docs/architecture/rfc` |

## Documentos que não pertencem a `contracts`

| Documento/grupo | Repositório recomendado | Motivo |
|---|---|---|
| ADRs de AWS, EKS, API Gateway e HPA | `garage-management-infra` | Decisões de plataforma e implantação. Migrados para `garage-management-infra/docs`. |
| ADR/RFC de CI/CD | Cada repositório de serviço e `garage-management-infra` | Processo de entrega, não contrato de domínio. |
| ADR/RFC de New Relic e `docs/observability` | `garage-management-infra` | Operação, dashboards, alertas e agentes. |
| ADRs de autenticação CPF/JWT/Lambda | `garage-management-lambda` | Emissão, validação e configuração de identidade. Migrados para `garage-management-lambda/docs`. |
| `target-architecture.md` | `garage-management-infra` | Arquitetura de implantação e topologia da plataforma. |
| RFCs de seleção de cloud e banco | `garage-management-infra` e `garage-management-database` | Decisões de infraestrutura e persistência. Migrados para os repositórios correspondentes. |
| `README.md` e `ROTEIRO.md` do `api-dotnet` | `garage-management-api-dotnet` | Operação e histórico da aplicação legada. |

## Regra para novos documentos

Um documento deve ser adicionado a este repositório somente se definir algo
consumido por mais de um serviço, como:

- schema de evento;
- payload ou versão de mensagem;
- vocabulário de domínio;
- cenário de aceitação distribuído;
- regra de compatibilidade de contratos.

Documentos sobre como executar, provisionar, monitorar ou proteger um serviço
devem permanecer no repositório responsável por essa operação.

## Documento obsoleto não distribuído

`architecture/adr/007-communication.md` não foi copiado porque descreve uma
arquitetura somente síncrona e afirma que não existe broker. Isso contradiz a
Saga atual com RabbitMQ. A decisão vigente está documentada em
[`saga-service-order-flow.md`](saga-service-order-flow.md).
