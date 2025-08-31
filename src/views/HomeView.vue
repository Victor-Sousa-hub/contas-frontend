<template>
  <div v-if="quadro">
    <div class="header">
      <h1>
        Dashboard Financeiro: {{ String(quadro.mes).padStart(2, "0") }}/{{
          quadro.ano
        }}
      </h1>
      <router-link :to="{ name: 'selecionar-quadro' }" class="btn btn-primary"
        >Trocar/Criar Quadro</router-link
      >
    </div>

    <div
      v-if="flashMessage"
      :class="['alert', `alert-${flashMessage.category}`]"
    >
      {{ flashMessage.text }}
    </div>

    <div class="card">
      <div class="card-header">Definir Salários do Mês</div>
      <form @submit.prevent="definirSalarios">
        <div class="grid-2">
          <div class="form-group">
            <label for="salario1">1º Salário (Dia 05)</label>
            <input
              type="number"
              step="0.01"
              name="salario1"
              id="salario1"
              class="form-control"
              v-model="formSalarios.salario1"
              required
            />
          </div>
          <div class="form-group">
            <label for="salario2">2º Salário (Dia 20)</label>
            <input
              type="number"
              step="0.01"
              name="salario2"
              id="salario2"
              class="form-control"
              v-model="formSalarios.salario2"
              required
            />
          </div>
        </div>
        <button type="submit" class="btn btn-primary">Salvar Salários</button>
      </form>
    </div>

    <h2>Resumo dos Saldos</h2>
    <div class="grid-2">
      <div class="card">
        <div class="card-header">Saldo (1º Salário)</div>
        <p><strong>Total:</strong> R$ {{ formatarMoeda(quadro.salario1) }}</p>
        <p>
          <strong>Gasto:</strong> R$ {{ formatarMoeda(resumoSaldos.gasto1) }}
        </p>
        <p>
          <strong>Restante: R$ {{ formatarMoeda(resumoSaldos.saldo1) }}</strong>
        </p>
      </div>
      <div class="card">
        <div class="card-header">Saldo (2º Salário)</div>
        <p><strong>Total:</strong> R$ {{ formatarMoeda(quadro.salario2) }}</p>
        <p>
          <strong>Gasto:</strong> R$ {{ formatarMoeda(resumoSaldos.gasto2) }}
        </p>
        <p>
          <strong>Restante: R$ {{ formatarMoeda(resumoSaldos.saldo2) }}</strong>
        </p>
      </div>
    </div>

    <h2>Dinheiro por Semana</h2>
    <div class="grid-4">
      <div class="card" v-for="semana in resumoSemanal" :key="semana.numero">
        <div class="card-header">
          {{ semana.numero }}ª Semana ({{ semana.dias[0] }}-{{
            semana.dias[semana.dias.length - 1]
          }})
        </div>
        <div class="semana-info">
          <p>
            <strong>Dinheiro inicial:</strong> R$
            {{ formatarMoeda(semana.dinheiro_inicial) }}
          </p>
          <p>
            <strong>Contas da semana:</strong> R$
            {{ formatarMoeda(semana.total_contas) }}
          </p>
          <p>
            <strong>Restante:</strong>
            <span
              :class="{
                positivo: semana.dinheiro_restante > 0,
                zero: semana.dinheiro_restante === 0,
              }"
            >
              R$ {{ formatarMoeda(semana.dinheiro_restante) }}
            </span>
          </p>
          <p v-if="semana.saldo_acumulado < 0">
            <strong>Déficit para próxima semana:</strong>
            <span class="negativo"
              >R$ {{ formatarMoeda(semana.saldo_acumulado) }}</span
            >
          </p>
          <details v-if="semana.contas && semana.contas.length">
            <summary>Contas da semana</summary>
            <ul>
              <li v-for="conta in semana.contas" :key="conta.id">
                {{ conta.descricao }} - R$ {{ formatarMoeda(conta.valor) }} ({{
                  formatarData(conta.data_vencimento)
                }})
              </li>
            </ul>
          </details>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">Adicionar Nova Conta</div>
      <form @submit.prevent="adicionarConta">
        <div class="form-group">
          <label for="descricao">Descrição da Conta</label>
          <input
            type="text"
            name="descricao"
            id="descricao"
            class="form-control"
            v-model="formConta.descricao"
            required
          />
        </div>
        <div class="grid-2">
          <div class="form-group">
            <label for="valor">Valor (R$)</label>
            <input
              type="number"
              step="0.01"
              name="valor"
              id="valor"
              class="form-control"
              v-model="formConta.valor"
              required
            />
          </div>
          <div class="form-group">
            <label for="data_vencimento">Data de Vencimento</label>
            <input
              type="date"
              name="data_vencimento"
              id="data_vencimento"
              class="form-control"
              v-model="formConta.data_vencimento"
              required
            />
          </div>
        </div>
        <div class="form-group">
          <label>Pagar com qual salário?</label>
          <input
            type="radio"
            name="fonte_pagamento"
            value="1"
            id="fonte1"
            v-model="formConta.fonte_pagamento"
            checked
          />
          <label for="fonte1">1º Salário</label>
          <input
            type="radio"
            name="fonte_pagamento"
            value="2"
            id="fonte2"
            v-model="formConta.fonte_pagamento"
          />
          <label for="fonte2">2º Salário</label>
        </div>
        <button type="submit" class="btn btn-primary">Adicionar Conta</button>
      </form>
    </div>

    <div class="grid-2">
      <div>
        <h3>Contas do 1º Salário</h3>
        <table>
          <thead>
            <tr>
              <th>Descrição</th>
              <th>Valor</th>
              <th>Vencimento</th>
              <th>Ação</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="conta in contas.salario1" :key="conta.id">
              <td>{{ conta.descricao }}</td>
              <td>R$ {{ formatarMoeda(conta.valor) }}</td>
              <td>{{ formatarDataLonga(conta.data_vencimento) }}</td>
              <td>
                <div class="acao-botoes">
                  <button class="btn btn-warning" @click="iniciarEdicao(conta)">
                    Editar
                  </button>
                  <button
                    class="btn btn-danger"
                    @click="excluirConta(conta.id)"
                  >
                    Excluir
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="!contas.salario1 || contas.salario1.length === 0">
              <td colspan="4">Nenhuma conta para o 1º salário.</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div>
        <h3>Contas do 2º Salário</h3>
        <table>
          <thead>
            <tr>
              <th>Descrição</th>
              <th>Valor</th>
              <th>Vencimento</th>
              <th>Ação</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="conta in contas.salario2" :key="conta.id">
              <td>{{ conta.descricao }}</td>
              <td>R$ {{ formatarMoeda(conta.valor) }}</td>
              <td>{{ formatarDataLonga(conta.data_vencimento) }}</td>
              <td>
                <div class="acao-botoes">
                  <button class="btn btn-warning" @click="iniciarEdicao(conta)">
                    Editar
                  </button>
                  <button
                    class="btn btn-danger"
                    @click="excluirConta(conta.id)"
                  >
                    Excluir
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="!contas.salario2 || contas.salario2.length === 0">
              <td colspan="4">Nenhuma conta para o 2º salário.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
  <div v-else>
    <p>Carregando...</p>
  </div>

  <div v-if="contaEditando" class="modal-overlay">
    <div class="modal-content card">
      <h3>Editar Conta</h3>
      <form @submit.prevent="salvarEdicao(formEdicao.id)">
        <div class="form-group">
          <label for="edit-descricao">Descrição</label>
          <input
            type="text"
            id="edit-descricao"
            class="form-control"
            v-model="formEdicao.descricao"
            required
          />
        </div>
        <div class="form-group">
          <label for="edit-valor">Valor (R$)</label>
          <input
            type="number"
            step="0.01"
            id="edit-valor"
            class="form-control"
            v-model="formEdicao.valor"
            required
          />
        </div>
        <div class="form-group">
          <label for="edit-data">Data de Vencimento</label>
          <input
            type="date"
            id="edit-data"
            class="form-control"
            v-model="formEdicao.data_vencimento"
            required
          />
        </div>
        <button type="submit" class="btn btn-primary">Salvar</button>
        <button type="button" class="btn btn-info" @click="cancelarEdicao">
          Cancelar
        </button>
      </form>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted, watch } from "vue";
import { useRoute } from "vue-router";
import axios from "axios";

export default {
  setup() {
    const route = useRoute();
    const quadro = ref(null);
    const resumoSaldos = ref({});
    const contas = ref({ salario1: [], salario2: [] });
    const resumoSemanal = ref([]);
    const flashMessage = ref(null);
    const contaEditando = ref(null);

    const API_URL = process.env.VUE_APP_API_URL || "http://localhost:5000/api";

    const formSalarios = reactive({
      salario1: 0,
      salario2: 0,
    });

    const formConta = reactive({
      descricao: "",
      valor: null,
      data_vencimento: "",
      fonte_pagamento: 1,
    });

    const formEdicao = reactive({
      id: null,
      descricao: "",
      valor: null,
      data_vencimento: "",
    });

    const carregarDadosDoQuadro = async (quadroId) => {
      try {
        const response = await axios.get(`${API_URL}/quadros/${quadroId}`);
        const data = response.data;
        quadro.value = data.quadro;
        resumoSaldos.value = data.resumo_saldos;
        contas.value = data.contas;
        resumoSemanal.value = data.resumo_semanal;

        formSalarios.salario1 = data.quadro.salario1;
        formSalarios.salario2 = data.quadro.salario2;
      } catch (error) {
        console.error("Erro ao carregar dados do quadro:", error);
      }
    };

    const iniciarEdicao = (conta) => {
      contaEditando.value = conta.id;
      formEdicao.id = conta.id;
      formEdicao.descricao = conta.descricao;
      formEdicao.valor = conta.valor;
      formEdicao.data_vencimento = conta.data_vencimento.slice(0, 10);
    };

    const salvarEdicao = async (contaId) => {
      try {
        const payload = {
          descricao: formEdicao.descricao,
          valor: formEdicao.valor,
          data_vencimento: formEdicao.data_vencimento,
        };
        await axios.put(`${API_URL}/contas/${contaId}`, payload);
        exibirMensagem("Conta editada com sucesso!", "success");
        contaEditando.value = null;
        carregarDadosDoQuadro(quadro.value.id);
      } catch (error) {
        exibirMensagem("Erro ao editar conta. Verifique os dados.", "danger");
      }
    };

    const cancelarEdicao = () => {
      contaEditando.value = null;
    };

    const definirSalarios = async () => {
      try {
        await axios.put(
          `${API_URL}/quadros/${quadro.value.id}/salarios`,
          formSalarios
        );
        exibirMensagem("Salários atualizados com sucesso!", "success");
        carregarDadosDoQuadro(quadro.value.id);
      } catch (error) {
        exibirMensagem("Erro ao atualizar salários.", "danger");
      }
    };

    const adicionarConta = async () => {
      try {
        const payload = { ...formConta, quadro_id: quadro.value.id };
        await axios.post(`${API_URL}/contas`, payload);
        exibirMensagem("Conta adicionada com sucesso!", "success");
        formConta.descricao = "";
        formConta.valor = null;
        formConta.data_vencimento = "";
        carregarDadosDoQuadro(quadro.value.id);
      } catch (error) {
        exibirMensagem(
          "Erro ao adicionar conta. Verifique os dados.",
          "danger"
        );
      }
    };

    const excluirConta = async (contaId) => {
      if (confirm("Tem certeza que deseja excluir esta conta?")) {
        try {
          await axios.delete(`${API_URL}/contas/${contaId}`);
          exibirMensagem("Conta excluída com sucesso!", "success");
          carregarDadosDoQuadro(quadro.value.id);
        } catch (error) {
          exibirMensagem("Erro ao excluir conta.", "danger");
        }
      }
    };

    const formatarMoeda = (valor) => {
      if (valor === undefined || valor === null) return "0,00";
      return parseFloat(valor).toFixed(2).replace(".", ",");
    };

    const formatarData = (dataString) => {
      const partes = dataString.split("-");
      return `${partes[2]}/${partes[1]}`;
    };

    const formatarDataLonga = (dataString) => {
      const partes = dataString.split("-");
      return `${partes[2]}/${partes[1]}/${partes[0]}`;
    };

    const exibirMensagem = (texto, categoria) => {
      flashMessage.value = { text: texto, category: categoria };
      setTimeout(() => {
        flashMessage.value = null;
      }, 5000); // 5 segundos
    };

    onMounted(() => {
      if (route.params.quadroId) {
        carregarDadosDoQuadro(route.params.quadroId);
      }
    });

    watch(
      () => route.params.quadroId,
      (newId) => {
        if (newId) {
          carregarDadosDoQuadro(newId);
        }
      }
    );

    return {
      quadro,
      resumoSaldos,
      contas,
      resumoSemanal,
      formSalarios,
      formConta,
      formEdicao,
      contaEditando,
      flashMessage,
      definirSalarios,
      adicionarConta,
      iniciarEdicao,
      salvarEdicao,
      cancelarEdicao,
      excluirConta,
      formatarMoeda,
      formatarData,
      formatarDataLonga,
      exibirMensagem,
    };
  },
};
</script>

<style scoped>
/* Estilos que você já tinha, mas com ajustes para o grid */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 10px;
  margin-bottom: 20px;
}

h2 {
  color: var(--cor-cinza-claro);
  font-size: 1.2rem;
  margin-top: 30px;
  margin-bottom: 10px;
}

/* Ajuste principal: Mobile-First */
.grid-2 {
  display: grid;
  grid-template-columns: 1fr; /* Por padrão, ocupa a largura total (1 coluna) */
  gap: 20px;
}

.grid-4 {
  display: grid;
  grid-template-columns: 1fr; /* Por padrão, ocupa a largura total (1 coluna) */
  gap: 15px;
}

/* Media Queries para telas maiores */
@media (min-width: 768px) {
  .grid-2 {
    grid-template-columns: 1fr 1fr; /* Em tablets, volta a ter duas colunas */
  }
  .grid-4 {
    grid-template-columns: repeat(2, 1fr); /* Em tablets, duas colunas */
  }
}

@media (min-width: 1024px) {
  .grid-4 {
    grid-template-columns: repeat(4, 1fr); /* Em desktops, quatro colunas */
  }
}

.card {
  background-color: var(--cor-card);
  border-radius: 20px;
  padding: 15px;
  margin-bottom: 15px;
  box-shadow: var(--sombra-card);
}

.card-header {
  font-weight: bold;
  margin-bottom: 10px;
  color: var(--cor-destaque);
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
  background-color: #4a4a61;
  color: var(--cor-texto-principal);
}

.btn {
  padding: 10px 15px;
  border: none;
  border-radius: 10px;
  color: var(--cor-card);
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

.btn-danger,
.btn-warning,
.btn-info {
  font-size: 12px;
  padding: 8px 10px;
  color: white;
}

.btn-danger {
  background-color: #e74c3c;
}
.btn-warning {
  background-color: #f39c12;
}
.btn-info {
  background-color: #17a2b8;
}

.alert {
  padding: 15px;
  margin-bottom: 20px;
  border-radius: 10px;
  color: white;
}

.alert-success {
  background-color: #2ecc71;
}
.alert-warning {
  background-color: #f1c40f;
}
.alert-danger {
  background-color: #e74c3c;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}

th,
td {
  text-align: left;
  padding: 12px;
  border-bottom: 1px solid var(--cor-card);
}

th {
  background-color: var(--cor-fundo);
  color: var(--cor-destaque);
}

tr:nth-child(even) {
  background-color: rgba(0, 0, 0, 0.1);
}

.positivo {
  color: var(--cor-destaque);
  font-weight: bold;
}
.negativo {
  color: #ff5252;
  font-weight: bold;
}
.zero {
  color: var(--cor-cinza-claro);
  font-weight: bold;
}

.semana-info p {
  margin: 5px 0;
}
details {
  margin-top: 10px;
}
summary {
  cursor: pointer;
  font-weight: bold;
  color: var(--cor-destaque);
}
details ul {
  margin: 5px 0;
  padding-left: 20px;
}
details li {
  margin: 2px 0;
  font-size: 14px;
}
</style>
