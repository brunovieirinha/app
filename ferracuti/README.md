# Ferracuti — Arquitetura de Interiores (site estático)

Versão local, estática e editável do site, reconstruída em **HTML + CSS** limpos
(sem build, sem dependências) a partir da alternativa de design feita no Lovable.

## Estrutura

```
ferracuti/
├── index.html        Projectos (página inicial)
├── servicos.html     Serviços
├── estudio.html      Estúdio
├── contacto.html     Contacto (com formulário)
├── styles.css        Folha de estilos partilhada por todas as páginas
└── assets/           Imagens (placeholders — substituir pelas fotos reais)
    ├── project-1.svg … project-6.svg
    └── studio.svg
```

## Como ver

Abre `index.html` no browser (basta duplo-clique), ou serve a pasta:

```bash
cd ferracuti
python3 -m http.server 8000
# abre http://localhost:8000
```

## Como editar

- **Texto / conteúdo:** diretamente em cada `.html`.
- **Cores, tipos de letra, espaçamentos:** no topo do `styles.css` (variáveis em
  `:root`). Paleta: creme (fundo), verde-sálvia (`--primary`), carvalho/verde-escuro
  (texto). Fontes: **Outfit** (títulos) + **Figtree** (texto), carregadas do Google Fonts.
- **Header/Footer:** são iguais nas quatro páginas; ao alterar um, replica nos restantes.

## Imagens

As `assets/*.svg` são **placeholders**. Para colocar as fotos reais:

1. Coloca as fotos em `assets/` (ex.: `project-1.jpg` … `project-6.jpg`, `studio.jpg`).
2. Atualiza o `src` no HTML (ex.: `assets/project-1.svg` → `assets/project-1.jpg`).

> As imagens originais do design estavam no servidor do Lovable, inacessível a partir
> do ambiente onde o site foi gerado — daí os placeholders.

## Formulário de contacto

O `<form>` em `contacto.html` é apenas a interface (não submete para lado nenhum).
Para o tornar funcional, liga-o a um serviço (Formspree, Netlify Forms, etc.) ou a um
endpoint próprio no atributo `action`.
