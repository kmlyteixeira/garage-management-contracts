Feature: Fluxo distribuído de ordem de serviço

  Scenario: OS aprovada é encaminhada para execução
    Given uma OS válida é aberta no os-service
    And o billing-service cria e aprova um orçamento para a OS
    When o pagamento é aprovado pelo Mercado Pago
    Then o billing-service publica PaymentApproved
    And o os-service publica ExecutionRequested
    And o execution-service cria a execução com status Queued
    And a OS permanece rastreável pelo mesmo correlationId

  Scenario: Falha no billing compensa a abertura
    Given uma OS válida é aberta no os-service
    When o billing-service rejeita a criação do orçamento
    Then o os-service marca a Saga como BillingFailed
    And o billing-service libera o estoque reservado
    And nenhuma execução é criada
