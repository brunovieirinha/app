<!-- VIEIRINHA121126 -->
# Playbook: apps pessoais para ganhar um extra

O que há de útil no género de conteúdo "faz uma app com IA e monetiza" (reels como o
"prompt de ouro" e a "auditoria de segurança"), filtrado do ruído, e com números de
2026 para decidir preço, paywall e expectativas. Usar na Fase 0 (perguntas sobre
dinheiro e PRD) e na Fase 3 (onboarding e paywall).

## 1. O que esse tipo de reels ensina de útil

Os bons têm um padrão comum, e é esse padrão que vale a pena manter:

| Ideia | Porque funciona |
|---|---|
| Perceber antes de construir, uma pergunta de cada vez | A maioria das apps falha por resolver um problema que ninguém tem. Oito perguntas custam dez minutos; um mês de código custa um mês. |
| PRD curto com "fora da primeira versão" | O que não entra é o que permite lançar. A lista de exclusões é o documento mais valioso. |
| Stack fixa e aborrecida | Expo + Supabase + Superwall é escolhido porque tem skills, docs e exemplos. Mudar de stack a meio é a forma mais cara de não lançar. |
| Fases com algo a funcionar hoje | Ver a ação principal no simulador no primeiro dia mantém a motivação e expõe cedo o que está mal pensado. |
| Plano aprovado antes de executar | Evita que a IA construa coisas a mais. O custo de um plano é zero; o custo de desfazer é alto. |
| Segurança como checklist, não como fase | Chaves no servidor, RLS, sessão no servidor, rate limiting. Feito antes do TestFlight custa uma tarde; feito depois de uma fatura surpresa de IA custa o projeto. |
| Verificar no simulador antes de dizer "feito" | "Compila" não é "funciona". A IA diz que está feito com demasiada facilidade. |
| Commit a cada coisa que funcione | Permite voltar atrás sem drama quando a IA estraga algo às 23h. |

O que ignorar nesse género de conteúdo:

- "10k/mês em 30 dias", "app em 1 hora". A mediana realista para uma primeira app com
  tração é 100 a 1 000 euros/mês ao fim do primeiro ano, e a maioria fica abaixo.
  Quase nenhuma primeira app é rentável nos primeiros 90 dias.
- Listas de "50 ideias de apps". Ideias não valem nada; distribuição e nicho valem tudo.
- Trocar de ferramenta a cada reel novo. A stack desta skill chega.
- Clonar a app da moda (contador de calorias com IA, diário com IA). Mercado saturado,
  custo de aquisição alto.

## 2. Escolher a ideia: cinco perguntas antes de abrir o Claude Code

1. **Quem é a pessoa, com nome e profissão?** "Pessoas que querem ser mais produtivas"
   não é ninguém. "Motorista de pesados que leva multa por errar as pausas" é alguém.
2. **Qual é a dor em euros ou em minutos?** Multa de 300 euros, 2 horas por semana em
   folhas de cálculo, um cliente perdido. Se não houver dor quantificável, não há
   subscrição.
3. **Onde é que essas pessoas já estão juntas?** Grupo de Facebook, subreddit,
   associação, fórum, feira. Se não souberes responder, não sabes como as vais
   encontrar depois, e é esse o problema real.
4. **O que usam hoje e porque é mau?** Lê as reviews de 1 a 3 estrelas dos
   concorrentes na App Store. É pesquisa de mercado grátis e concreta.
5. **Consegues ser utilizador da tua própria app?** As melhores apps de um só
   programador resolvem um problema que ele tem ou conhece de perto.

**Vantagem a explorar**: conhecimento de domínio. Quem trabalha em logística,
transporte, armazém e farmácia conhece dores reais e específicas (controlo de
temperatura em entregas, validades em farmácia, pausas de motoristas, paletes e
cargas, documentação aduaneira, checklists de carga) que os programadores de
produtividade genérica não vêem. Nichos profissionais aguentam preços mais altos
(9,99 a 19,99 euros/mês) se pouparem horas ou evitarem multas.

**Portugal ou global?** Começa com a app em português e inglês desde o primeiro dia
(i18n custa pouco no início e muito depois), com 8 ou mais idiomas na ficha da App
Store a partir da Fase 4. O mercado português sozinho raramente paga uma app; o nicho
global, sim.

## 3. Validar sem escrever código (uma semana, no máximo)

- Página simples com a promessa e uma lista de espera (pode ser um formulário).
- Cinco conversas de 15 minutos com pessoas do público-alvo. Perguntar como fazem hoje,
  não se "usariam uma app".
- Pesquisar na App Store os 5 concorrentes: preço, modelo, reviews más.
- Se ninguém quiser falar contigo sobre o problema, também não vai pagar para o resolver.

## 4. Modelo de preço: o que os dados de 2026 dizem

Fontes principais: relatório State of Subscription Apps 2026 da RevenueCat (115 mil
apps) e as novas regras da App Store na União Europeia em vigor desde 1 de outubro de
2026. Os números são medianas; a tua app pode estar longe delas.

**Subscrição ou compra única?**
- Subscrição com trial é o padrão para apps com uso recorrente (hábitos, registos,
  acompanhamento). Compra única (ou "lifetime" ao lado da anual) para utilitários
  simples que se usam poucas vezes (conversores, calculadoras, ferramentas de
  ocasião). Oferecer anual + lifetime juntos costuma aumentar a receita total.
- Apps de IA geram cerca de 39% mais receita no primeiro mês, mas perdem clientes
  30% mais depressa. Se houver IA, o teto de gastos da auditoria é obrigatório.

**Paywall rígido ou freemium?**
- Paywall rígido (tem de subscrever ou iniciar trial para usar) converte cerca de 5
  vezes melhor que freemium: cerca de 10,7% de trial para pago ao dia 35, contra 2,1%.
  Receita mediana por instalação com paywall rígido: cerca de 2,3 dólares, e acima de
  4,5 no quartil superior.
- Freemium faz sentido quando o produto precisa de volume para funcionar (efeitos de
  rede, conteúdo gerado por utilizadores) ou quando a primeira versão ainda não vale
  dinheiro. Para uma app de nicho de um só programador, começa com paywall rígido com
  trial, e mede.

**Trial**
- Trials de 7 dias ou mais convertem claramente melhor que trials de 3 dias, embora a
  tendência do mercado seja encurtar. Recomendação: 7 dias, com notificação dois dias
  antes de acabar (é também o que a Apple e os utilizadores esperam para não haver
  reembolsos).
- A maior parte das apps que convertem fá-lo no dia 0: o paywall no fim do onboarding
  é onde a decisão acontece. Depois disso, a probabilidade cai a pique.

**Preços de partida**
- Utilitário ou consumidor: 4,99 euros/mês e 29,99 a 39,99 euros/ano. Anual em
  destaque, com o desconto visível ("poupa 40%").
- Nicho profissional que poupa horas ou multas: 9,99 a 19,99 euros/mês, anual com
  desconto.
- Fixa o preço pelo valor para o utilizador, não pelo custo de servidor. Subir preço
  depois é fácil; descer dá sensação de desespero.
- Expectativa de retenção: cerca de 72% dos subscritores anuais não renovam no segundo
  ano (mediana 2026). O negócio vive de aquisição contínua, não de uma base fixa.

**Comissões (o que fica no teu bolso)**
- Inscreve-te no App Store Small Business Program (menos de 1 milhão de dólares/ano):
  comissão de 15% em vez de 30%, no mundo inteiro. 4,99 euros brutos são cerca de 4,24
  líquidos antes de IVA.
- Na UE, desde 1 de outubro de 2026, os termos unificados mantêm 15% para pequenos
  programadores nas compras pela App Store, com 10% para pagamentos alternativos ou
  link para a web. Para uma app pequena, não vale a pena a complexidade dos pagamentos
  alternativos no arranque; StoreKit via Superwall chega.
- Lembra-te do IVA: a Apple trata-o, mas o preço "4,99" inclui-o. A receita que vês no
  App Store Connect é já líquida de IVA e de comissão.

## 5. Onboarding e paywall: o que converte

- 3 a 4 ecrãs, cada um com uma ideia: o problema (a pessoa reconhece-se), a promessa
  (o que muda), a personalização (1 ou 2 perguntas cujas respostas a app usa mesmo),
  e o pedido de notificações com motivo concreto ("avisamos 10 minutos antes da pausa").
- O paywall no fim mostra: o benefício em 3 linhas, o plano anual em destaque com o
  preço por mês equivalente, o trial ("7 dias grátis, depois X/ano, cancela quando
  quiseres"), e os botões de restaurar compras e de fechar (a Apple exige que se possa
  fechar; esconder o X dá rejeição).
- Superwall permite mudar texto, preços e layout do paywall sem nova build nem review.
  Usa-o para testar duas versões de cada vez, uma variável por teste, durante pelo
  menos 2 semanas ou 200 visualizações.
- Pedir review (`StoreReview.requestReview`) só depois de um momento de sucesso (a
  ação principal concluída pela terceira vez, por exemplo). Nunca no arranque.

## 6. Métricas: os cinco eventos e metas iniciais

| Passo | Evento | Meta inicial razoável |
|---|---|---|
| Abriu a app | `app_aberta` | 100% (base) |
| Acabou o onboarding | `onboarding_concluido` | 60 a 75% dos que abriram |
| Viu o paywall | `paywall_visto` | igual ao onboarding (está no fim) |
| Iniciou trial ou subscreveu | `subscreveu` | 5 a 10% dos que viram o paywall |
| Fez a ação principal | `acao_principal` | 3 ou mais vezes na primeira semana por quem subscreveu |

Trial para pago: 30 a 40% é bom para paywall rígido com trial de 7 dias; abaixo de
15% o problema é o produto ou o público, não o paywall.

Olha para estes números uma vez por semana, não todos os dias. Com menos de 100
instalações por semana, qualquer variação é ruído.

## 7. Lançar e ser encontrado (ASO) sem orçamento

- **Nome e subtítulo** com as palavras que o público escreve na pesquisa ("pausas
  motorista", "tacógrafo", não o nome bonito da marca). O nome pode ter a marca e a
  keyword: "Pausa Certa: tacógrafo".
- **Screenshots** com uma frase grande por imagem a explicar o benefício. São o que
  vende, não a descrição.
- **8 ou mais idiomas na ficha** (título, subtítulo, keywords, screenshots), mesmo que
  a app só tenha 2. Multiplica as pesquisas em que apareces.
- **Atualizações frequentes** (a cada 2 a 4 semanas) contam para o ranking e para a
  confiança. EAS Update para correções sem review.
- **Distribuição inicial**: os sítios da pergunta 3 da secção 2. Um post honesto ("fiz
  isto porque tinha este problema, é grátis 7 dias, digam-me o que falta") num grupo
  do nicho vale mais do que o Product Hunt para uma app de nicho.
- **Reviews**: responde a todas, sobretudo às más. As respostas aparecem na ficha.
- Gastar em anúncios só depois de saber o valor de um subscritor (receita anual por
  pagante) e só se o custo por instalação for claramente inferior a esse valor
  multiplicado pela conversão. Antes disso é queimar dinheiro.

## 8. Custos reais e expectativas

| Item | Custo |
|---|---|
| Apple Developer Program | 99 dólares/ano (obrigatório) |
| Supabase | grátis até 2 projetos pequenos; 25 dólares/mês quando crescer |
| Superwall | plano gratuito até um volume de receita; depois percentagem |
| PostHog, Sentry | planos gratuitos chegam para uma app pequena |
| EAS Build | plano gratuito com builds limitadas por mês; 19 dólares/mês se precisar de mais |
| Domínio + página de privacidade/termos | 10 a 20 euros/ano |
| Chaves de IA (se houver) | variável; o teto de gastos é o que impede surpresas |
| Mac com Xcode | necessário para compilar e verificar no simulador |

Expectativa honesta: com nicho bem escolhido e distribuição feita, 100 a 1 000
euros/mês ao fim do primeiro ano é um bom resultado. Cerca de 1% dos programadores
independentes chega aos 100 mil dólares/ano. A segunda e a terceira app custam uma
fração da primeira, porque a stack, as skills e o processo já estão feitos: é aí
que o "extra" se torna consistente.

## 9. Depois do lançamento: regra dos 90 dias

Todas as semanas, 30 minutos: ver os cinco eventos, ler as reviews novas, responder,
lançar uma correção pequena. Ao fim de 90 dias, decidir com números:

- **Crescer**: há pagantes, a conversão trial para pago está acima de 25%, e as
  reviews pedem funcionalidades concretas. Pegar na primeira da lista "fora da
  primeira versão".
- **Mudar**: há instalações mas ninguém paga. O problema é o paywall ou a promessa.
  Testar preço e mensagem com o Superwall antes de escrever código novo.
- **Parar**: menos de 100 instalações por mês sem crescimento e sem canal de
  distribuição à vista. Deixar a app publicada (custa zero), tirar as lições, e
  começar a próxima com a mesma stack. Cada app seguinte demora metade do tempo.

## 10. Como alimentar este playbook com reels novos

Esta sessão não consegue ler o Instagram (precisa de login). Para extrair o que
interessa de um reel novo, envia uma captura de ecrã do texto ou a transcrição, como
fizeste com o "prompt de ouro" e a auditoria. O critério para entrar aqui: a ideia
tem de ser aplicável a uma app de nicho de um só programador, verificável com um
número ou um passo concreto, e não depender de comprar o curso de quem a publicou.

## Fontes

- RevenueCat, State of Subscription Apps 2026: https://www.revenuecat.com/state-of-subscription-apps
- RevenueCat, resumo em 10 minutos: https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026
- Apple, alterações para apps na União Europeia (agosto de 2026): https://www.apple.com/newsroom/2026/08/apple-announces-changes-for-apps-in-the-european-union/
- Adapty, App Store Small Business Program: https://adapty.io/blog/app-store-small-business-program/
- Expectativas de receita para apps independentes: https://youcouldshipthis.com/blog/indie-app-revenue-realistic-expectations
- Guia de monetização iOS para independentes: https://theswiftk.it.com/blog/how-to-monetize-ios-app-indie-developer
