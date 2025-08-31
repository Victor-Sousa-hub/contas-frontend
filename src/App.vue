<template>
  <div id="app" class="container">
    <router-view />
  </div>
</template>

<script>
export default {
  name: "App",
};
</script>

<style>
/* Paleta de Cores e Tipografia */
:root {
  --cor-fundo: #1b1b2f;
  --cor-card: #2c2c44;
  --cor-texto-principal: #e0e0e0;
  --cor-destaque: #00d995;
  --cor-cinza-claro: #8a8a9a;
  --sombra-card: 0 4px 12px rgba(0, 0, 0, 0.2);
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
    "Helvetica Neue", Arial, sans-serif;
  background-color: var(--cor-fundo);
  color: var(--cor-texto-principal);
  margin: 0;
  padding: 0; /* Remove o padding do body */
}

/* Container principal com bordas arredondadas */
.container {
  max-width: 1000px;
  margin: 20px auto;
  background-color: transparent; /* O fundo do container principal deve ser transparente para mostrar o fundo da página */
  padding: 20px;
  border-radius: 20px;
  box-shadow: none;
}

h1,
h2,
h3 {
  color: var(--cor-texto-principal);
}

a {
  color: var(--cor-destaque);
  text-decoration: none;
}
</style>
