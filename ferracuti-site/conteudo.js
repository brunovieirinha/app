/* ============================================================================
   VIEIRINHA040726 — fotografias reais dos projetos importadas do Wix
   VIEIRINHA040726 — criação inicial do site

   FERRACUTI — Arquitetura e Design de Interiores
   FICHEIRO DE CONTEÚDO — conteudo.js

   Este é o ÚNICO ficheiro que precisa de editar para atualizar o site.
   Não é preciso mexer no index.html.

   ─────────────────────────────────────────────────────────────────────────
   COMO ADICIONAR UM PROJETO NOVO (5 passos):

   1. Copie as fotografias do projeto para a pasta  img/projetos/
      Use nomes simples, sem espaços nem acentos.
      Exemplo:  cozinha-porto-1.jpg , cozinha-porto-2.jpg , ...

   2. Mais abaixo, na lista "projetos", copie um bloco existente
      (tudo desde a chaveta {  até  },  incluída) e cole-o no fim
      da lista, antes do  ]  de fecho. Não esqueça a vírgula entre blocos.

   3. Altere no bloco novo:
        titulo:    o nome do projeto (aparece no site)
        categoria: "residencial", "comercial" ou "3d"
        capa:      a fotografia principal  → "img/projetos/cozinha-porto-1.jpg"
        galeria:   as restantes fotografias, entre parêntesis retos
        destaque:  true para dar mais protagonismo na grelha, senão false

   4. Grave este ficheiro. Pode abrir o index.html no browser para confirmar
      que está tudo bem (se uma foto faltar, o site mostra um padrão elegante
      em vez de uma imagem partida — nada fica "estragado").

   5. Para publicar: vá a app.netlify.com, entre no site e arraste a pasta
      ferracuti-site inteira para a área de "Deploys". Pronto, está online.

   NOTA: em cada alteração futura, acrescente no topo deste ficheiro um
   comentário  VIEIRINHA + data (DDMMAA), ex.:  VIEIRINHA151226 — novo projeto
   ─────────────────────────────────────────────────────────────────────────
============================================================================ */

const CONTEUDO = {

  /* ── CONTACTO ──────────────────────────────────────────────────────────
     Número de WhatsApp em formato internacional, só dígitos
     (351 = Portugal, seguido do número, sem espaços). */
  whatsapp: "351932046474",

  /* Mensagem que aparece pré-escrita quando alguém clica num botão
     de WhatsApp do site. */
  mensagemWhatsapp: "Olá! Gostaria de saber mais sobre os vossos projetos.",

  /* ── REDES SOCIAIS ──────────────────────────────────────────────────── */
  redes: {
    instagram: "https://www.instagram.com/ferracutiarquitetura/",
    facebook: "https://www.facebook.com/arq.sandraferracuti",
    linkedin: "https://www.linkedin.com/in/sandra-ferracuti-455444a3/"
  },

  /* ── SOBRE ──────────────────────────────────────────────────────────── */
  sobre: {
    foto: "img/sandra.jpg",
    texto: "Sou Sandra Ferracuti, arquiteta ítalo-brasileira apaixonada pelo que faço. Nascida e formada no Brasil, com raízes italianas, escolhi Portugal como o meu lar há sete anos. Desde então, crio projetos que valorizam cada detalhe, com equilíbrio entre estética e funcionalidade, para responder às reais necessidades de quem utiliza o espaço. A minha especialidade são os projetos de interiores — lugares que refletem as necessidades e a personalidade de quem os vive, seja para morar, trabalhar ou simplesmente estar."
  },

  /* ── PROJETOS ───────────────────────────────────────────────────────────
     categoria: "residencial" | "comercial" | "3d"
     capa:      fotografia principal (aparece na grelha)
     galeria:   restantes fotografias (aparecem no visualizador, a seguir à capa)
     destaque:  true = célula maior na grelha                                  */
  projetos: [
    {
      titulo: "Ginásio — Canidelo",
      categoria: "comercial",
      capa: "img/projetos/ginasio-canidelo-1.jpg",
      galeria: [
        "img/projetos/ginasio-canidelo-2.jpg",
        "img/projetos/ginasio-canidelo-3.jpg",
        "img/projetos/ginasio-canidelo-4.jpg",
        "img/projetos/ginasio-canidelo-5.jpg",
        "img/projetos/ginasio-canidelo-6.jpg"
      ],
      destaque: true
    },
    {
      titulo: "Ginásio — Afurada",
      categoria: "comercial",
      capa: "img/projetos/ginasio-afurada-1.jpg",
      galeria: [
        "img/projetos/ginasio-afurada-2.jpg",
        "img/projetos/ginasio-afurada-3.jpg",
        "img/projetos/ginasio-afurada-4.jpg",
        "img/projetos/ginasio-afurada-5.jpg",
        "img/projetos/ginasio-afurada-6.jpg"
      ],
      destaque: false
    },
    {
      titulo: "Painel de TV",
      categoria: "residencial",
      capa: "img/projetos/painel-tv-1.jpg",
      galeria: [
        "img/projetos/painel-tv-2.jpg"
      ],
      destaque: false
    },
    {
      titulo: "Quarto de Bebé",
      categoria: "residencial",
      capa: "img/projetos/quarto-bebe-1.jpg",
      galeria: [
        "img/projetos/quarto-bebe-2.jpg",
        "img/projetos/quarto-bebe-3.jpg",
        "img/projetos/quarto-bebe-4.jpg",
        "img/projetos/quarto-bebe-5.jpg"
      ],
      destaque: false
    },
    {
      titulo: "Quarto de Solteiro",
      categoria: "residencial",
      capa: "img/projetos/quarto-solteiro-1.jpg",
      galeria: [
        "img/projetos/quarto-solteiro-2.jpg",
        "img/projetos/quarto-solteiro-3.jpg"
      ],
      destaque: false
    },
    {
      titulo: "Sala de Reuniões",
      categoria: "comercial",
      capa: "img/projetos/sala-reunioes-1.jpg",
      galeria: [
        "img/projetos/sala-reunioes-2.jpg",
        "img/projetos/sala-reunioes-3.jpg",
        "img/projetos/sala-reunioes-4.jpg"
      ],
      destaque: false
    },
    {
      titulo: "Receção e Sala de Espera — Clínica",
      categoria: "comercial",
      capa: "img/projetos/clinica-rececao-1.jpg",
      galeria: [
        "img/projetos/clinica-rececao-2.jpg",
        "img/projetos/clinica-rececao-3.jpg",
        "img/projetos/clinica-rececao-4.jpg"
      ],
      destaque: false
    },
    {
      titulo: "Receção e Sala de Espera — Gabinete Jurídico",
      categoria: "comercial",
      capa: "img/projetos/gabinete-juridico-1.jpg",
      galeria: [
        "img/projetos/gabinete-juridico-2.jpg"
      ],
      destaque: false
    }
  ],

  /* ── DEPOIMENTOS ────────────────────────────────────────────────────── */
  depoimentos: [
    {
      autor: "Pedro Ribeiro",
      texto: "Recomendo fortemente os serviços da Sandra Ferracuti, excelente profissional que conjuga a estética com a funcionalidade elevando os projetos a um nível superior!"
    },
    {
      autor: "Chris Duque Estrada",
      texto: "Profissional excelente que entende os desejos dos clientes. Criativa, detalhista, empática e com atendimento impecável. Já fizemos um projeto e pretendemos fazer outros. Super recomendo."
    },
    {
      autor: "Dayana Cláudia Couto",
      texto: "Missão quase impossível de refazer o quarto do meu filho adolescente, pequeno e nada funcional. Mesmo à distância, elaborou o projeto mais perfeito que eu nem conseguia imaginar. Indico de olhos fechados!"
    },
    {
      autor: "Raquel Oliveira",
      texto: "Competência e profissionalismo ímpares. Impecável — obrigada por captar toda a essência."
    },
    {
      autor: "Ingrid Ferfeman",
      texto: "Serviço profissional e de excelente qualidade."
    }
  ]
};
