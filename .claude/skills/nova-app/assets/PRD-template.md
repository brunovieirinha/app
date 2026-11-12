# PRD: [Nome da app]

<!-- VIEIRINHA121126 -->
_Versão 1, [data]. Documento vivo: atualizar quando o âmbito mudar._

## 1. Problema

[Dois ou três parágrafos curtos. Quem sofre, com o quê, em que momento, e o que
acontece hoje quando não há solução. Escrever na perspetiva da pessoa, não da app.]

## 2. Utilizador-alvo

- **Quem**: [perfil concreto, com um exemplo de pessoa real ou plausível]
- **Quando usa**: [momento do dia / situação]
- **O que usa hoje**: [app concorrente, folha de cálculo, papel, nada]
- **Porque mudaria**: [o ganho concreto]

## 3. Ação principal

[Uma frase. A única coisa que a app tem de fazer bem no primeiro dia. Tudo o resto
existe para servir esta ação.]

## 4. Funcionalidades principais (primeira versão)

| # | Funcionalidade | Fase | Porque entra |
|---|---|---|---|
| 1 | [ação principal] | 1 | É a razão de a app existir |
| 2 | Conta e sincronização | 2 | |
| 3 | Onboarding + paywall | 3 | |
| 4 | [outra, só se for mesmo necessária] | | |

## 5. Fora da primeira versão

[A lista mais importante do documento. Tudo o que foi mencionado e não entra, com um
motivo de uma linha. Fica aqui para não se perder e para não entrar por engano.]

- [funcionalidade]: [motivo]
- [funcionalidade]: [motivo]

## 6. Fluxo do utilizador (primeiro ecrã até ao paywall)

1. Abre a app → [ecrã]
2. Onboarding: [ecrã 1] → [ecrã 2] → [ecrã 3]
3. Paywall: [o que mostra, o que fica grátis, o que fica bloqueado]
4. Subscreve ou continua grátis → [ecrã da ação principal]
5. Faz a ação principal → [resultado visível]

## 7. Modelo de negócio

- **O que é grátis**: [...]
- **O que é pago**: [...]
- **Preço**: [mensal / anual / compra única, valores]
- **Porque alguém paga**: [uma frase honesta]

## 8. Como medimos se está a funcionar

| Métrica | Evento PostHog | Meta inicial |
|---|---|---|
| Abriram a app | `app_aberta` | |
| Acabaram o onboarding | `onboarding_concluido` | [% dos que abriram] |
| Viram o paywall | `paywall_visto` | |
| Subscreveram | `subscreveu` | [% dos que viram o paywall] |
| Fizeram a ação principal | `acao_principal` | [por utilizador por semana] |

## 9. Riscos e dúvidas em aberto

- [risco ou pergunta sem resposta, e quando a vamos responder]
