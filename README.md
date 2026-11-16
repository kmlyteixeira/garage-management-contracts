# Garage Management Contracts

Contratos versionados de eventos e mensagens compartilhados pelos microsserviços.

Este repositório não contém lógica de negócio nem é dependência de runtime. Os
serviços devem validar e publicar eventos compatíveis com os schemas deste
repositório.

## Versões

- `events/service-order-events.v1.json`: envelope dos eventos da Saga de ordem
  de serviço.
- [`docs/saga-service-order-flow.md`](docs/saga-service-order-flow.md): diagrama
  de sequência, fluxo de sucesso, compensações e estados da Saga.
- [`docs/ubiquitous-language.md`](docs/ubiquitous-language.md): vocabulário
  comum dos bounded contexts.
- [`docs/acceptance/service-order-flow.feature`](docs/acceptance/service-order-flow.feature):
  cenários de aceitação do fluxo distribuído.
- [`docs/documentation-inventory.md`](docs/documentation-inventory.md):
  classificação da documentação legada e critérios de pertencimento.

Alterações incompatíveis devem criar uma nova versão do schema. Alterações
compatíveis podem ser adicionadas mantendo os campos existentes.
