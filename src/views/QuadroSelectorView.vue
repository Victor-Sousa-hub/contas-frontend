<template>
  <div>
    <div class="header">
      <h1>Controle de Contas</h1>
    </div>

    <div class="grid-2">
      <div class="card">
        <h3>Criar Novo Quadro Mensal</h3>
        <form @submit.prevent="criarQuadro">
          <div class="form-group">
            <label for="ano">Ano</label>
            <select v-model="novoQuadro.ano" id="ano" class="form-control">
              <option v-for="a in anos" :key="a" :value="a">{{ a }}</option>
            </select>
          </div>
          <div class="form-group">
            <label for="mes">Mês</label>
            <select v-model="novoQuadro.mes" id="mes" class="form-control">
              <option v-for="m in 12" :key="m" :value="m">
                {{ String(m).padStart(2, "0") }}
              </option>
            </select>
          </div>
          <button type="submit" class="btn btn-primary">
            Criar e Acessar Quadro
          </button>
        </form>
      </div>

      <div class="card">
        <h3>Selecionar Quadro Existente</h3>
        <ul v-if="quadros.length">
          <li v-for="quadro in quadros" :key="quadro.id">
            <router-link
              :to="{ name: 'home', params: { quadroId: quadro.id } }"
            >
              Quadro de {{ String(quadro.mes).padStart(2, "0") }}/{{
                quadro.ano
              }}
            </router-link>
          </li>
        </ul>
        <p v-else>Nenhum quadro foi criado ainda.</p>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRouter } from "vue-router";

export default {
  setup() {
    const router = useRouter();
    const quadros = ref([]);
    const anos = ref([]);
    const novoQuadro = ref({
      ano: new Date().getFullYear(),
      mes: new Date().getMonth() + 1,
    });

    const API_URL = process.env.VUE_APP_API_URL || "https://contas-api-knswlw.fly.dev/api";

    const carregarQuadros = async () => {
      try {
        const response = await axios.get(`${API_URL}/quadros`);
        quadros.value = response.data;
      } catch (error) {
        console.error("Erro ao carregar os quadros:", error);
      }
    };

    const carregarAnos = () => {
      const anoAtual = new Date().getFullYear();
      for (let i = anoAtual; i <= anoAtual + 5; i++) {
        anos.value.push(i);
      }
    };

    const criarQuadro = async () => {
      try {
        const response = await axios.post(
          `${API_URL}/quadros`,
          novoQuadro.value
        );
        router.push({
          name: "home",
          params: { quadroId: response.data.quadro_id },
        });
      } catch (error) {
        console.error("Erro ao criar quadro:", error);
        if (error.response && error.response.status === 409) {
          alert("O quadro para este mês e ano já existe!");
          router.push({
            name: "home",
            params: { quadroId: error.response.data.quadro_id },
          });
        }
      }
    };

    onMounted(() => {
      carregarQuadros();
      carregarAnos();
    });

    return {
      quadros,
      anos,
      novoQuadro,
      criarQuadro,
    };
  },
};
</script>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 10px;
  margin-bottom: 20px;
}

.grid-2 {
  display: grid;
  grid-template-columns: 1fr; /* Muda para uma coluna por padrão em mobile */
  gap: 20px;
}

@media (min-width: 768px) {
  .grid-2 {
    grid-template-columns: 1fr 1fr; /* Volta a ter duas colunas em telas maiores */
  }
}

.card {
  background-color: var(--cor-card);
  border-radius: 20px; /* Bordas arredondadas como na imagem */
  padding: 15px;
  margin-bottom: 15px;
  box-shadow: var(--sombra-card);
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: var(--cor-texto-principal);
}

.form-control {
  width: 100%;
  padding: 10px;
  box-sizing: border-box;
  border: none;
  border-radius: 10px;
  background-color: #4a4a61; /* Um cinza mais escuro para o input */
  color: var(--cor-texto-principal);
}

.btn {
  padding: 10px 15px;
  border: none;
  border-radius: 10px;
  color: var(--cor-card); /* Botões com texto escuro e fundo claro */
  text-decoration: none;
  font-size: 16px;
  cursor: pointer;
  font-weight: bold;
  transition: background-color 0.3s ease;
}

.btn-primary {
  background-color: var(--cor-destaque);
}

.btn-primary:hover {
  background-color: #00b377;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  margin-bottom: 10px;
}
</style>
