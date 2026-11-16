# Linguagem ubíqua

Vocabulário compartilhado pelos contratos e pelos três bounded contexts.

| Termo | Definição | Termo em inglês |
|---|---|---|
| Ordem de Serviço (OS) | Registro central que representa o ciclo de atendimento do veículo. | Service Order |
| Cliente | Pessoa física ou jurídica que solicita serviços. | Customer |
| Veículo | Bem do cliente submetido aos serviços, identificado por placa, modelo e ano. | Vehicle |
| Serviço | Atividade executada no veículo. | Service |
| Peça / Insumo | Item físico utilizado na execução dos serviços. | Product |
| Estoque | Controle da quantidade disponível de peças e insumos. | Inventory |
| Orçamento | Valor calculado com base nos serviços e peças da OS. | Quote |
| Aprovar orçamento | Ação que autoriza a continuidade do atendimento. | Approve Quote |
| Rejeitar orçamento | Ação que recusa o orçamento e inicia a compensação da reserva. | Reject Quote |
| Diagnóstico | Análise técnica para identificar serviços e peças necessários. | Diagnosis |
| Status da OS | Estado atual da ordem de serviço no fluxo distribuído. | Service Order Status |
| Em diagnóstico | Estado em que o veículo está sendo analisado. | In Diagnosis |
| Em execução | Estado em que os serviços estão sendo realizados. | In Repair |
| Finalizada | Estado após a conclusão dos serviços. | Finished |
| Entregue | Estado após a devolução do veículo ao cliente. | Delivered |
| Mecânico | Profissional responsável pela execução dos serviços. | Mechanic |
| Correlation ID | Identificador que conecta comandos, eventos, logs e traces da mesma Saga. | Correlation ID |
| Causation ID | Identificador do evento ou comando que causou a mensagem atual. | Causation ID |
| Evento de domínio | Fato ocorrido em um bounded context, publicado para os demais serviços. | Domain Event |
| Compensação | Ação local que desfaz um efeito já confirmado quando uma etapa posterior falha. | Compensation |

## Contextos

| Contexto | Dono |
|---|---|
| Abertura, cadastro e ciclo de vida da OS | OS Service |
| Catálogo, orçamento, estoque e pagamento | Billing Service |
| Diagnóstico, reparo e conclusão da execução | Execution Service |
