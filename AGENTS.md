# AGENTS.md

## Instrucciones para el asistente

No ejecutar ninguna acción de escritura de `git` ni `gh` (commit, push, crear/borrar branches, tags, releases, cambios de configuración del repo/Pages, etc.). Si hace falta alguna de estas acciones, indicar los comandos para que el usuario los corra a mano.

Guía para crear nuevas visualizaciones didácticas de Programación Avanzada. Hay tres familias:
- **Tablas de Programación Dinámica** (`dp/knapsack.html`, `dp/lcs.html`, `dp/edit-distance.html`): layout de 2 columnas, tabla HTML interactiva.
- **Diagramas en Canvas** (`recursion/call-tree.html`): layout full-bleed, dibujo imperativo en `<canvas>`.
- **Grafos con panel de código** (`grafos/dfs.html`, `grafos/bfs.html`, `grafos/dijkstra.html`): full-bleed con panel lateral, grafo animado en `<canvas>` (2/3) + pseudocódigo/explicación (1/3).

Las reglas de stack/idioma, **Modo claro/oscuro**, **Persistencia/"Nuevo"/Compartir por URL**, **Footer** y **Portada** aplican a **las tres familias**. Para crear una visualización nueva, copiar el archivo existente más parecido en forma (una tabla → `dp/lcs.html`; un diagrama/grafo sin código → `recursion/call-tree.html`; un algoritmo paso a paso sobre un grafo → `grafos/dfs.html`) y adaptar.

## Reglas duras

- **Un solo archivo `.html`, autocontenido.** Nada de build, nada de archivos separados de JS/CSS.
- **Todo vía CDN, con versión fijada** (no `@latest`):
  - Bootstrap `5.3.3` — solo el CSS (`bootstrap.min.css`). No cargar `bootstrap.bundle.min.js` a menos que se use un componente JS de Bootstrap real (`data-bs-*`).
  - Vue `3` global build (`unpkg.com/vue@3/dist/vue.global.js`) — Composition API (`setup()`). Destructurar de `Vue` solo lo que se use.
  - KaTeX `0.16.10` (CSS + `katex.min.js`) desde `cdn.jsdelivr.net`. No cargar `auto-render.min.js`: el render es siempre manual con `katex.render()`.
- Bootstrap lo más plano posible: componentes estándar (`navbar`, `card`, `table`, `badge`, `list-group`, `btn`), sin JS custom de Bootstrap, sin utilidades exóticas.
- **Idioma: español** (`lang="es"`), UI y textos explicativos.
- **KaTeX se renderiza a mano** con `katex.render(...)` sobre `document.getElementById(...)`, dentro de `renderExplanation()` llamada después de `nextTick()`.

## Estructura de página (Familia 1: tabla de PD)

```
<nav class="navbar navbar-dark bg-dark px-3">   → título con emoji + badge "DP · O(...)"
<div class="container-fluid py-3">
  <div class="row g-3">
    <!-- Columna izquierda: col-12 col-md-4 col-xl-3 -->
      - card "Parámetros"/"Cadenas de entrada" (inputs de datos)
      - (opcional) card de costos/configuración extra
      - botón "▶ Resolver" (btn-dark w-100)
      - card "Leyenda" (list-group, un badge de color por cada tipo de dependencia)
      - firma (ver Footer)
    <!-- Columna derecha: col-12 col-md-8 col-xl-9 -->
      - estado vacío (antes de resolver): card centrada con emoji grande + instrucción
      - banner de resultado (card border-success): valor/resultado destacado + reconstrucción
      - card "Tabla de Programación Dinámica": tabla con thead table-dark, celdas .dp-cell clicleables
      - card "🔍 Explicación paso a paso": fórmula general | sustitución numérica, con badge de veredicto
```

## Convención de interacción con la tabla

- Cada celda: `class="dp-cell"` + una clase condicional según su rol (`cellClass(i, j)`):
  - `.cell-selected` (verde) — celda clickeada.
  - Una clase `.cell-dep-*` por cada celda de la que depende la recurrencia, con el mismo color que su badge en la Leyenda.
- Paleta por rol de dependencia (usar siempre variables CSS de Bootstrap, nunca hex fijo — son las que se adaptan al modo claro/oscuro):
  - Verde (`--bs-success-bg-subtle` / `--bs-success-border-subtle`) — celda seleccionada.
  - Amarillo (`--bs-warning-bg-subtle` / `--bs-warning-border-subtle`) — diagonal / coincidencia / "incluir".
  - Azul (`--bs-primary-bg-subtle` / `--bs-primary-border-subtle`) — arriba / "no incluir" / eliminar.
  - Rojo (`--bs-danger-bg-subtle` / `--bs-danger-border-subtle`) — izquierda / insertar.
  - No le pongas un color propio a un caso que en realidad depende de la misma celda que otro (ej. "sustituir" en `edit-distance.html` comparte diagonal con "igualar": mismo amarillo).
  - Hover de celda: `--bs-tertiary-bg`. Bordes de acento: `--bs-border-color`.
- **Celdas de cabecera/índice** (thead y columna de `<th>` de etiquetas de fila): clase `.dp-header-cell` (`background-color: var(--bs-secondary-bg-subtle) !important; color: var(--bs-emphasis-color) !important;`) — nunca `table-secondary text-dark` (rompe en modo oscuro: hereda `color: white` del `thead.table-dark` ancestro). Etiquetas chicas dentro (`i=`, `j=`): `text-muted`.
- Clic en celda → `selectCell(i, j)` guarda selección y llama `nextTick(() => renderExplanation(i, j))`, que llena `#formula-box` (fórmula general con índices concretos) y `#subst-box` (misma fórmula con valores sustituidos, terminando en el resultado en negrita).
- Un computed `verdictBadge`/`verdictIcon`/`verdictText` resume en una frase + ícono + color qué rama de la recurrencia se tomó.
- La solución se resuelve al cargar (`nextTick(solve)`) y también con el botón "Resolver".

## Familia 2: visualizaciones basadas en Canvas (`recursion/`)

Para diagramas/grafos (árboles de llamadas, DAGs), no el layout de 2 columnas. Referencia: `recursion/call-tree.html`.

- **Layout full-bleed**: `#app` flex-column a `height:100vh` — navbar delgado, `.canvas-container` (`flex:1 1 auto; position:relative; overflow:hidden`) con `<canvas>` a `width/height:100%`, y `.footer-bar` al pie fuera del canvas.
- **Vue para estado de UI, dibujo imperativo**: sin `watch`; cada función que muta estado llama `draw()` al final. `reactive()` es válido para agrupar la cámara (`{offsetX, offsetY, scale}`).
- **`ref(null)` + `ref="nombre"`** en el template para los nodos DOM (`<canvas>`, contenedor, `<input>` flotante).
- **KaTeX opcional**, mismo patrón manual (`katex.render(source, el, { throwOnError: false })`).
- **Paleta por tema como objeto JS plano** (`PALETTES = { light: {...}, dark: {...} }`), no variables CSS (`ctx.fillStyle` no resuelve `var(--bs-*)`).
- **`devicePixelRatio` obligatorio**: `canvas.width/height` en píxeles físicos, `ctx.setTransform(dpr,0,0,dpr,0,0)`. Recalcular en cada resize.
- **Overlays HTML flotantes** (toolbar, `<input>` de edición, panel de ecuación) van `position:absolute` dentro de `.canvas-container`, posicionados vía `worldToScreen`. Nunca texto editable ni controles dentro del canvas.
- **Layout automático de árbol**: ancho de subárbol proporcional a su cantidad de hojas (Reingold-Tilford simplificado). Profundidad → Y fija por nivel.
- **Cámara**: `fitToView()` recalcula `scale`/`offset` tras cada cambio estructural, salvo pan/zoom manual (`userAdjustedCamera`); botón "Ajustar vista" la reactiva. No se persiste entre sesiones.
- **Aristas "extra" (no jerárquicas)**: curva cuadrática (`ctx.quadraticCurveTo`), punto de control = punto medio desplazado en la perpendicular (`bow = distancia * 0.2`). El hit-testing reusa la misma función de curva (`pointOnQuadratic`), nunca recalcular geometría dos veces.
- **Selección**: nodo y arista mutuamente excluyentes (`selectedId` / `selectedEdgeId`), cada uno con su toolbar flotante. Clic en vacío o Escape limpia todo.
- **Persistencia/URL**: ver sección universal abajo. `currentState()` junta nodos + aristas + ecuación (nunca cámara ni selecciones). `resetToDefault()` vacía todo el diagrama.
- **Nodos nuevos heredan la etiqueta del padre**: `addChild(parentId)` copia `parent.label` como valor inicial.
- **Contadores de nodos**: cada banda de nivel muestra la cantidad de nodos de ese nivel (`countsByDepth`, calculado una vez por `draw()`). Total del diagrama en badge del navbar (`🔢 N nodos`, oculto si vacío).

## Familia 3: grafos con panel de código (`grafos/`)

Para algoritmos paso a paso sobre un grafo genérico (DFS/BFS y similares), donde además del grafo hace falta mostrar el pseudocódigo con la línea actual resaltada, una explicación de cada paso, y estructuras de datos del algoritmo (pila, cola, conjuntos, arrays auxiliares). Referencia: `grafos/dfs.html` (pila + conjunto de visitados) y `grafos/bfs.html` (cola + array de distancias); `grafos/dijkstra.html` es la variante con pesos, grafo dirigido opcional, panel de datos (matriz/D/P/cola) al lado del grafo, tabla de seguimiento por iteración debajo y KaTeX para la relajación — son el mismo esqueleto de interfaz y ejecución, solo cambian `PSEUDOCODE`, `computeSteps()` y la(s) estructura(s) de datos que muestran los overlays flotantes.

- **Layout full-bleed con panel lateral**: `#app` flex-column a `height:100vh` — navbar, una fila `.main-row` (`flex:1 1 auto; display:flex`) con `.canvas-wrap` (`flex:2 1 0`, el grafo) y `.code-panel` (`flex:1 1 0; overflow-y:auto`, código + explicación), y `.footer-bar` al pie de todo el ancho (no dentro de ninguna de las dos columnas). En pantallas angostas (`@media max-width: 768px`), `.main-row` pasa a `flex-direction: column`.
- **Grafo genérico, no jerárquico**: un solo array `edges: [{a, b, key}]` (sin `parentId`), no dirigido. La lista de adyacencia (`Map<label, label[]>`) se arma recorriendo las aristas en el orden en que fueron declaradas — ese orden es el que usa el algoritmo para "Adyacentes(grafo, v)".
- **Entrada de datos por texto, no editor visual**: un textarea con la lista de aristas (`A-B` por línea o separadas por coma; un token sin guion declara un nodo aislado), con un botón "▶ Aplicar" explícito — no autoguardar en cada tecla. Sin selección de nodo/arista ni toolbar flotante por nodo: toda la edición estructural pasa por el textarea, así que el único gesto sobre el canvas es arrastrar un nodo para reacomodarlo.
- **Layout inicial circular** (no Reingold-Tilford, que es para árboles): al parsear, los nodos ya existentes conservan su posición (`x`/`y`) y los nuevos se ubican en un círculo según su índice en la lista total de nodos. Las posiciones sí son arrastrables a mano y sí se persisten (a diferencia de la cámara).
- **Pasos precalculados, no simulación en vivo**: una función (`computeSteps`) corre el algoritmo real una sola vez con sus estructuras reales (pila/cola/conjuntos) y empuja un snapshot por cada punto de parada didáctico (`{activeLines, stack, visited, ..., badge, highlightEdge}`) a un array `steps`. "Paso siguiente/anterior", autoplay (`setInterval` simple) y el índice de progreso son solo un puntero sobre ese array — nunca se vuelve a ejecutar el algoritmo al navegar.
- **Clasificación de aristas persistente**: cada arista se clasifica (ej. `'tree'`/`'discard'`) la primera vez que el algoritmo la examina, y esa clasificación queda fija para siempre — si se la vuelve a examinar desde el otro extremo, no se reclasifica.
- **Panel de código**: un pseudocódigo fijo (array de strings, mismo texto que el enunciado del algoritmo) renderizado línea por línea con `white-space: pre`; la(s) línea(s) activa(s) de `steps[currentStepIndex].activeLines` llevan una clase que las resalta (`--bs-warning-bg-subtle`). Debajo, un badge de veredicto (ícono + color + frase en lenguaje llano) igual al patrón `verdictBadge` de Familia 1, tomado directo de `steps[currentStepIndex].badge`.
- **Estructuras de datos como overlays flotantes**: pila/cola/visitados se muestran en cards `position:absolute` ancladas a una esquina fija de `.canvas-wrap` (no a `worldToScreen`, porque no siguen a ningún nodo en particular) — mismo mecanismo que el panel de ecuación de Familia 2.
- **Sin KaTeX** si el algoritmo no tiene fórmulas que renderizar (no cargar la librería de arranque; sumarla solo si hace falta).

## Persistencia, "Nuevo" y Compartir por URL (obligatorio)

Apoyado en dos helpers idénticos por archivo:

```js
function encodeState(data) { return encodeURIComponent(JSON.stringify(data)); }
function decodeState(str) { return JSON.parse(decodeURIComponent(str)); }
```

Y dos funciones propias de cada herramienta que nunca deben repetir la lista de campos en más de un lugar:
- `currentState()` — objeto plano con todo el estado editable (nunca selección, cámara u otro estado transitorio).
- `applyState(data)` — vuelca ese objeto sobre los refs, con fallback al valor actual si falta un campo (`data.campo ?? actual`).

1. **Autoguardado en localStorage.** Key fija por herramienta (`pa-tools-<familia>-<nombre>`). `persist()` hace `localStorage.setItem(STORAGE_KEY, JSON.stringify(currentState()))`:
   - Familia 1: `watch([...refs], persist)` (`{ deep: true }` si hay arrays/objetos mutados en profundidad).
   - Familia 2: llamado explícito al final de cada función que muta estado.

2. **Botón "🆕 Nuevo"** en el navbar, confirmación de 2 pasos (nunca `confirm()` nativo):
   ```js
   const newConfirm = ref(false);
   function handleNewClick() {
     if (newConfirm.value) { resetToDefault(); return; }
     newConfirm.value = true;
     setTimeout(() => { if (newConfirm.value) newConfirm.value = false; }, 3000);
   }
   ```
   `resetToDefault()` vuelve a valores de ejemplo hardcodeados (Familia 1) o vacía el diagrama (Familia 2).

3. **Botón "🔗 Compartir"**: URL con el estado codificado en el **hash** (`#d=...`, nunca query string):
   ```js
   const shareCopied = ref(false);
   function shareCurrentState() {
     const url = `${location.origin}${location.pathname}#d=${encodeState(currentState())}`;
     const onCopied = () => { shareCopied.value = true; setTimeout(() => { shareCopied.value = false; }, 2000); };
     if (navigator.clipboard?.writeText) {
       navigator.clipboard.writeText(url).then(onCopied).catch(() => window.prompt('Copiá el link:', url));
     } else {
       window.prompt('Copiá el link:', url);
     }
   }
   ```
   Al montar, `loadInitialState()` — la URL gana sobre localStorage si está presente:
   ```js
   function loadInitialState() {
     if (location.hash.startsWith('#d=')) {
       try {
         applyState(decodeState(location.hash.slice(3)));
         history.replaceState(null, '', location.pathname + location.search);
         persist();
         return;
       } catch (e) { console.error('No se pudo leer la configuración de la URL:', e); }
     }
     loadFromStorage();
   }
   ```

Sin compresión ni librerías — el JSON entra cómodo en una URL a esta escala.

## Modo claro/oscuro (obligatorio)

Mecanismo nativo de Bootstrap 5.3 (`data-bs-theme` en `<html>`), no librería ni tema custom.

1. **Script de inicialización en el `<head>`, antes del `<link>` de Bootstrap** (evita parpadeo, respeta preferencia guardada o del sistema):
   ```html
   <script>
     (function () {
       const stored = localStorage.getItem('theme');
       const theme = stored || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
       document.documentElement.setAttribute('data-bs-theme', theme);
     })();
   </script>
   ```
2. **`<body>` sin `class="bg-light"`** ni ningún `bg-*`/`text-*` fijo.
3. **Botón de toggle en el navbar**, agrupado con el badge de complejidad en `div.d-flex`:
   ```html
   <div class="d-flex align-items-center gap-2">
     <span class="badge bg-secondary">DP · O(n·W)</span>
     <button class="btn btn-sm btn-outline-light" @click="toggleTheme" :title="isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'">{{ isDark ? '☀️' : '🌙' }}</button>
   </div>
   ```
   ```js
   const isDark = ref(document.documentElement.getAttribute('data-bs-theme') === 'dark');
   function toggleTheme() {
     isDark.value = !isDark.value;
     const theme = isDark.value ? 'dark' : 'light';
     document.documentElement.setAttribute('data-bs-theme', theme);
     localStorage.setItem('theme', theme);
   }
   ```
   Si la página no usa Vue (como `index.html`), mismo botón con `id` fijo (`theme-toggle-btn`) + JS vanilla equivalente — ver `index.html`.

- No mezclar el botón dentro de `#app` con `<script>` sueltos ahí adentro (Vue compila ese `innerHTML` como template, no se re-ejecuta al montar).
- Toda caja/celda con color (tabla DP, cajas de fórmula) usa variables `--bs-*-subtle` de Bootstrap, nunca hex fijo. Las cajas de KaTeX (`#formula-box`, `#subst-box`) usan `bg-body-tertiary`, no `bg-white`.
- Chips que muestran texto crudo de entrada (ej. `bg-light text-dark border`) se dejan fijos — es un chip de "código", legible en cualquier tema a propósito.

## Footer (obligatorio, idéntico en toda página — incluida la portada)

```html
<p> Hecho con ❤️ por <a href="https://github.com/programacion-avanzada">Programación Avanzada</a> (y <a href="https://claude.ai">Claude</a>)</p>
```

En las visualizaciones, al final de la columna izquierda dentro de `<div class="mt-4 mb-4">`. En `index.html`, al final del `<div class="container">` dentro de `<div class="mt-5 mb-3">`. No cambiar texto, orden de links, ni agregar iconos.

## Portada (`index.html`)

Única página sin Vue ni KaTeX — listado estático. Mismo `<head>` (script de tema + Bootstrap CSS), mismo navbar, tarjetas `card` (emoji + nombre + badge) agrupadas por sección (`<h2 class="h5">`), footer al final. Una familia nueva es solo otro `<h2>` + `.row`.

**Al agregar una visualización nueva, actualizar `index.html`** (tarjeta nueva, mismo emoji que su navbar) además de la fila en `README.md`.

## Checklist para una visualización nueva (Familia 1: tabla de PD)

Para Canvas (Familia 2), seguir la sección "Familia 2" arriba y copiar `recursion/call-tree.html`; para grafos con panel de código (Familia 3), seguir la sección "Familia 3" y copiar `grafos/dfs.html`. En ambos casos los pasos 5 y 7 de abajo aplican igual.

1. Copiar cualquiera de los tres archivos existentes como plantilla.
2. Cambiar: `<title>`, texto del navbar (emoji + nombre + badge de complejidad), inputs de la columna izquierda, y `solve()`.
3. Definir la paleta de `.cell-dep-*` según cuántas dependencias **distintas** tiene la recurrencia, con variables `--bs-*-bg-subtle`/`--bs-*-border-subtle`.
4. Escribir `renderExplanation()`: fórmula general en LaTeX (`\begin{cases}`) + sustitución numérica paso a paso.
5. Mantener footer y toggle de tema idénticos.
6. Actualizar `currentState()`/`applyState()` con los campos propios (de ahí sale gratis autoguardado, "Nuevo" y compartir por URL). `resetToDefault()` vuelve a los valores de ejemplo hardcodeados.
7. Antes de dar por terminada la visualización, revisar que no queden imports, clases CSS, variables o funciones sin usar.
8. Actualizar `README.md` (fila nueva) y `index.html` (tarjeta nueva).
