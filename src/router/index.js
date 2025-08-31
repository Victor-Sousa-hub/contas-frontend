import { createRouter, createWebHistory } from "vue-router";
import QuadroSelectorView from "../views/QuadroSelectorView.vue";
import HomeView from "../views/HomeView.vue"; // Esta linha é crucial

const routes = [
  {
    path: "/",
    name: "selecionar-quadro",
    component: QuadroSelectorView,
  },
  {
    path: "/quadro/:quadroId",
    name: "home",
    component: HomeView, // Esta linha é crucial
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
