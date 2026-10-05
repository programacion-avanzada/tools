# AGENTS.md

## Instrucciones para el asistente

Guía para crear nuevas visualizaciones didácticas de Programación Avanzada. Hay tres familias:
- **Tablas de Programación Dinámica** (`dp/knapsack.html`, `dp/lcs.html`, `dp/edit-distance.html`): layout de 2 columnas, tabla HTML interactiva.
- **Diagramas en Canvas** (`recursion/call-tree.html`): layout full-bleed, dibujo imperativo en `<canvas>`.
- **Grafos con panel de código** (`grafos/dfs.html`, `grafos/bfs.html`, `grafos/dijkstra.html`, `grafos/prim.html`, `grafos/kruskal.html`): full-bleed con panel lateral, grafo animado en `<canvas>` (2/3) + pseudocódigo/explicación (1/3).

Las reglas de stack/idioma, **Modo claro/oscuro**, **Persistencia/"Nuevo"/Compartir por URL**, **Footer** y **Portada** aplican a **las tres familias**. Para crear una visualización nueva, copiar el archivo existente más parecido en forma (una tabla → `dp/lcs.html`; un diagrama/grafo sin código → `recursion/call-tree.html`; un algoritmo paso a paso sobre un grafo → `grafos/dfs.html`) y adaptar.

## Reglas duras

- **Un solo archivo `.html`, autocontenido.** Nada de build, nada de archivos separados de JS/CSS.
- **Todo vía CDN, con versión fijada** (no `@latest`):
  - Bootstrap `5.3.3` — solo el CSS (`bootstrap.min.css`). No cargar `bootstrap.bundle.min.js` a menos que se use un componente JS de Bootstrap real (`data-bs-*`).
  - Vue `3` global build (`unpkg.com/vue@3/dist/vue.global.js`) — Composition API (`setup()`). Destructurar de `Vue` solo lo que se use.
  - KaTeX `0.16.10` (CSS + `katex.min.js`) desde `cdn.jsdelivr.net`. No cargar `auto-render.min.js`: el render es siempre manual con `katex.render()`.
- Bootstrap lo más plano posible: componentes estándar (`navbar`, `card`, `table`, `badge`, `list-group`, `btn`), sin JS custom de Bootstrap, sin utilidades exóticas.
- **Idioma: español** (`lang="es"`), UI y textos explicativos.
- **KaTeX se renderiza a mano** con `katex.render(...)` sobre `document.getElementById(...)`, dentro de `renderExplanation()` llamada después de `nextTick()`. Única excepción: la card de complejidad (ver "Complejidad desplegable"), que usa `katex.renderToString` + `v-html`.

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

**Variante sin tabla clickeable (`recursion/teorema-maestro.html`)**: mismo layout de 2 columnas y mismas convenciones (watch + persist, KaTeX manual en `renderMath()` tras `nextTick`, banner + badge de veredicto), pero la columna derecha es un análisis que se recalcula en vivo al cambiar los inputs (sin botón "Resolver"): desarrollo en KaTeX, tabla por nivel y un gráfico de barras en HTML/CSS (sin librería). El color de caso se aplica con una clase `.case-*` que define `--case-bg`/`--case-strong` a partir de variables `--bs-*`.

**Variante con gráfico (`complejidad/comparador.html`)**: mismo layout de 2 columnas, con un gráfico de líneas en `<svg>` dentro del template (sin librería), dibujado en píxeles al ancho real de la card (medido con `ResizeObserver`). **No usar `viewBox` en los SVG del template**: como el template vive dentro del HTML, el navegador pasa los atributos a minúscula y `viewbox` no lo entiende el SVG. Colores de series: paleta categórica validada con el skill `dataviz` para los fondos de Bootstrap (claro y oscuro), asignada por posición de la función en la lista (fija, no por orden de marcado); desde la 9ª se repite el tono con otro trazo. Los valores se manejan como log10 para no desbordar. Las funciones propias se evalúan con un parser de descenso recursivo, **nunca con `eval`**: el estado viaja en la URL de Compartir.

`complejidad/big-o.html` reusa el mismo esqueleto (parser seguro, gráfico SVG medido) con dos series fijas (T(n) en el color de texto y c·g(n) en `--bs-danger`, como en la teoría) y una verificación numérica (`analyze`, `minC`, `minN0`) que siempre dice hasta dónde verificó.

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
- **Nodos nuevos heredan la etiqueta del padre**: `addChild(parentId)` copia `parent.label` como valor inicial. Lo mismo `growSubtree(nodeId)` (🌿), que crea `growLevels` niveles de `growChildren` hijos por nodo de una vez, con un tope de `MAX_GROW` nodos por operación.
- **Pintar nodos y flechas**: mismo panel, paleta `DRACULA`, `darken`/`textColorOn` y `LINE_STYLES` que `grafos/editor.html` (copiados; `DASHES` como arrays para `ctx.setLineDash`). El color vive en `node.color`, el trazo de la flecha padre → hijo en `node.edgeStyle` del hijo y el de las flechas extra en `edge.style` (por defecto `'dashed'`), así que viajan solos en `currentState()`. Con un modo de pintar activo, el clic pinta en vez de seleccionar.
- **Deshacer**: `persist()` compara el JSON de `currentState()` con el último guardado y, si cambió, apila el anterior (`undoStack`, tope `MAX_UNDO`); `undo()` lo vuelve a aplicar. Así cualquier función que ya llama a `persist()` queda deshaciable sin tocarla. Ctrl+Z se ignora dentro de inputs.
- **Export PNG**: `draw()` es un envoltorio de `renderScene(ctx, w, h, { background, highlights })`; el export llama a `renderScene` sobre un canvas aparte con una cámara temporal a escala 1 que encuadra todo el árbol (bounding box de nodos + curvas extra), sin selección, a `EXPORT_SCALE` px por px. Sin fondo: solo el árbol + 1em.
- **Contadores de nodos**: cada banda de nivel muestra la cantidad de nodos de ese nivel (`countsByDepth`, calculado una vez por `draw()`). Total del diagrama en badge del navbar (`🔢 N nodos`, oculto si vacío).

## Familia 3: grafos con panel de código (`grafos/`)

Para algoritmos paso a paso sobre un grafo genérico (DFS/BFS y similares), donde además del grafo hace falta mostrar el pseudocódigo con la línea actual resaltada, una explicación de cada paso, y estructuras de datos del algoritmo (pila, cola, conjuntos, arrays auxiliares). Referencia: `grafos/dfs.html` (pila + conjunto de visitados) y `grafos/bfs.html` (cola + array de distancias); `grafos/dijkstra.html` es la variante con pesos, grafo dirigido opcional, panel de datos (matriz/D/P/cola) al lado del grafo, tabla de seguimiento por iteración debajo y KaTeX para la relajación — `grafos/prim.html` reusa ese mismo esqueleto (sin dirigido ni KaTeX) con una cola de aristas `(peso, u, v)` y una lista del MST, y `grafos/kruskal.html` lo reusa con la cola completa, un Union-Find ingenuo (vector `padre[]` + bosque en `<svg>`) y los vértices coloreados por subárbol — son el mismo esqueleto de interfaz y ejecución, solo cambian `PSEUDOCODE`, `computeSteps()` y la(s) estructura(s) de datos que muestran los overlays flotantes.

- **Layout full-bleed con panel lateral**: `#app` flex-column a `height:100vh` — navbar, una fila `.main-row` (`flex:1 1 auto; display:flex`) con `.canvas-wrap` (`flex:2 1 0`, el grafo) y `.code-panel` (`flex:1 1 0; overflow-y:auto`, código + explicación), y `.footer-bar` al pie de todo el ancho (no dentro de ninguna de las dos columnas). En pantallas angostas (`@media max-width: 768px`), `.main-row` pasa a `flex-direction: column`.
- **Grafo genérico, no jerárquico**: un solo array `edges: [{a, b, key}]` (sin `parentId`), no dirigido. La lista de adyacencia (`Map<label, label[]>`) se arma recorriendo las aristas en el orden en que fueron declaradas — ese orden es el que usa el algoritmo para "Adyacentes(grafo, v)".
- **Entrada de datos por texto, no editor visual**: un textarea con la lista de aristas (`A-B` por línea o separadas por coma; un token sin guion declara un nodo aislado), con un botón "▶ Aplicar" explícito — no autoguardar en cada tecla. Sin selección de nodo/arista ni toolbar flotante por nodo: toda la edición estructural pasa por el textarea, así que el único gesto sobre el canvas es arrastrar un nodo para reacomodarlo.
- **Layout inicial circular** (no Reingold-Tilford, que es para árboles): al parsear, los nodos ya existentes conservan su posición (`x`/`y`) y los nuevos se ubican en un círculo según su índice en la lista total de nodos. Las posiciones sí son arrastrables a mano y sí se persisten (a diferencia de la cámara).
- **Pasos precalculados, no simulación en vivo**: una función (`computeSteps`) corre el algoritmo real una sola vez con sus estructuras reales (pila/cola/conjuntos) y empuja un snapshot por cada punto de parada didáctico (`{activeLines, stack, visited, ..., badge, highlightEdge}`) a un array `steps`. "Paso siguiente/anterior", autoplay (`setInterval` simple) y el índice de progreso son solo un puntero sobre ese array — nunca se vuelve a ejecutar el algoritmo al navegar.
- **Clasificación de aristas persistente**: cada arista se clasifica (ej. `'tree'`/`'discard'`) la primera vez que el algoritmo la examina, y esa clasificación queda fija para siempre — si se la vuelve a examinar desde el otro extremo, no se reclasifica.
- **Panel de código**: un pseudocódigo fijo (array de strings, mismo texto que el enunciado del algoritmo) renderizado línea por línea con `white-space: pre`; la(s) línea(s) activa(s) de `steps[currentStepIndex].activeLines` llevan una clase que las resalta (`--bs-warning-bg-subtle`). Debajo, un badge de veredicto (ícono + color + frase en lenguaje llano) igual al patrón `verdictBadge` de Familia 1, tomado directo de `steps[currentStepIndex].badge`.
- **Estructuras de datos como overlays flotantes**: pila/cola/visitados se muestran en cards `position:absolute` ancladas a una esquina fija de `.canvas-wrap` (no a `worldToScreen`, porque no siguen a ningún nodo en particular) — mismo mecanismo que el panel de ecuación de Familia 2.
- **Orden de nodos en matrices y vectores** (tablas indexadas por nodo): siempre `sortLabels()` — numérico si todas las etiquetas son números, si no lexicográfico (`localeCompare`, sin `numeric`: "10" antes que "2"). Copiar la función de `grafos/dijkstra.html`. Las estructuras con orden propio del algoritmo (pila, cola, visitados en orden de visita) no se reordenan.
- **KaTeX**: lo carga toda herramienta de algoritmos por la card de complejidad, aunque el algoritmo no tenga otras fórmulas.
- **Estructuras de datos (`estructuras/heap.html`)**: mismo esqueleto de pasos precalculados + pseudocódigo con línea activa + historial de operaciones (como `grafos/union-find.html`), sin canvas. El árbol completo se dibuja en `<svg>` con posición exacta por índice (nivel ⌊log₂ i⌋) y cada nodo es un `<g>` con `key` = id del elemento (no la posición). La animación es en JS (`animateTo`, requestAnimationFrame) y no con `transition` de CSS, porque al reordenarse el `v-for` Vue mueve un `<g>` en el DOM y ese pierde la transición: cada nodo que cambia de posición viaja por una curva cuadrática con el control corrido a la izquierda del recorrido, así los dos de un intercambio orbitan hacia lados opuestos sin taparse; un nodo nuevo crece desde su padre y uno que se va se achica. Las posiciones del árbol (y sus aristas) también se animan, y el tamaño del `<svg>` es fijo para toda la secuencia, anclado arriba, así el árbol no salta al sumar un nivel. En headless las capturas no corren `requestAnimationFrame`: para verlas, reemplazarlo por un `setTimeout`. Una operación en vivo se agrega a la secuencia y reproduce únicamente sus pasos (`play(hasta)`).
- **Coloreo (`grafos/coloreo.html`)**: mismo esqueleto que `prim.html`, con un `<select>` de modo (Secuencial / Welsh-Powell / Matula) que cambia la función principal del pseudocódigo (`MODES[mode].main` + `COMMON_CODE`) y el `orden`. Los colores asignados son los de `DRACULA` (copiados de `editor.html`); desde el 9 se generan con un hash fijo por número (`colorHex`), y el número del color se muestra siempre (chip en el nodo y en los arrays) para que dos colores parecidos no se confundan. Un segundo `<select>` elige la estrategia (`STRATEGIES`: por vértice / por color), que cambia el bloque de soporte (`COMMON_CODE[strategy]`), el loop de `computeSteps` (`colorByVertex` / `colorByColor`) y la tabla de seguimiento; para un mismo orden ambas dan el mismo coloreo.
- **Variante sin grafo (`grafos/union-find.html`)**: sin canvas. Grilla 2×2 de cards (una por variante de Union-Find) con `id[]`/`sz[]` + bosque en `<svg>` (`forestLayout` copiado de `kruskal.html`) + pseudocódigo estático de `find`/`union`/`connected`/`count` (sin línea activa; las líneas que cambian respecto de la variante anterior se marcan con `+` en `pseudo()` y van en verde), y panel lateral con la entrada en vivo, el historial (= pasos) y la tabla comparativa. Cada operación es un paso precalculado para las 4 variantes; los accesos se cuentan con `rd`/`wr` instrumentados.
- **Variante sin algoritmo (`grafos/editor.html`)**: solo el grafo a todo el ancho, sin panel de código ni pasos. Dibuja con un `<svg>` en el template de Vue (no canvas) porque su objetivo es exportar: el `<g>` del grafo se serializa tal cual a SVG y se rasteriza a PNG transparente. Colores inline desde `PALETTES` (no `var(--bs-*)`) para que el archivo exportado los lleve. Compartir incluye `{graphText, directed, colors, styles}` (sin posiciones).
  - **Matriz de adyacencia**: card flotante arriba a la derecha (`showMatrix`, no se persiste), `computed` a partir de `edges`/`directed`; `sortLabels` copiado de `dijkstra.html`.
  - **Export PPTX**: PptxGenJS `4.0.1` (excepción a la lista de CDNs, solo acá), cargado con un `<script>` dinámico recién al exportar, no en el `<head>`. PptxGenJS no genera conectores: las aristas se emiten como líneas con `objectName` (`e0`, `e1`...) y después se reescriben en `slide1.xml` como `<p:cxnSp>` con `stCxn`/`endCxn` hacia los nodos (`n0`, `n1`...), usando el `JSZip` que trae el bundle. Ese retoque depende del XML de esa versión exacta: si se actualiza PptxGenJS, volver a probar el import en Google Slides moviendo un nodo. Los costos quedan como texto suelto (un conector no puede llevar texto).

## Complejidad desplegable (obligatorio en herramientas de algoritmos)

Toda herramienta que muestra un algoritmo (DP, grafos, estructuras) lleva una card `<details class="card">` cerrada por defecto con `<summary class="card-header fw-semibold">⏱️ Complejidad: <span v-html="tex(complexity.total)"></span></summary>` (CSS: `summary.card-header { cursor: pointer; }`). Va antes de la Leyenda del panel de explicación (en DP, debajo de "🔍 Explicación paso a paso"). Sin JS ni estado, no se persiste.

- Los datos viven en una constante `COMPLEXITY = { total, headers, rows, note }` antes de `createApp` y se exponen como `complexity` en el `return` del `setup()`. Si depende de la configuración, es un `computed` (`coloreo.html`: `complexityFor(mode, strategy)`, y el badge del navbar usa `complexity.badge`, el mismo total en texto plano). En `union-find.html` el título dice "según la variante", sin `total`.
- `headers` suele ser `['Línea', 'Veces', 'Costo']` (en DP `'Paso'`, porque no hay pseudocódigo en pantalla); cada fila es `[línea del pseudocódigo, veces que se ejecuta, costo total]`, con el texto del `PSEUDOCODE` de la herramienta. `union-find.html` usa una columna por variante.
- `note` suma los costos en prosa y aclara lo que no sale de la tabla (memoria, peor caso con la implementación de la herramienta, alternativas).
- `total`, las celdas de `rows` salvo la primera (código, en monoespaciada) son LaTeX y se renderizan con `tex(s)` (`katex.renderToString` + `v-html`: las celdas salen de un `v-for`, sin `id` ni `nextTick`). `note` es texto con fórmulas entre `$…$`, renderizado con `texInline(s)` (parte por `$`, escapa el texto plano); no usar `auto-render`. Los dos helpers se copian tal cual y se exponen junto a `complexity`. Si el navbar muestra el mismo total, va aparte en texto plano (`badge` en `coloreo.html`).

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

En cada herramienta, el título del navbar es el link de vuelta a la portada: `<a class="navbar-brand mb-0 h5" href="../index.html" title="Volver a todas las herramientas"><span class="opacity-75 me-1">←</span>🎒 Nombre</a>`.

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

## Commits

- Mensajes simples y cortos, en español, describiendo el cambio.
- Solamente el mensaje: sin coautorías, sin menciones a IA ni metadatos extra.
- Revisar `git status` antes de `git add` y agregar solo los archivos que correspondan al cambio.
- Un commit por cambio lógico; separar cambios independientes en commits distintos.
- No ejecutar acciones destructivas o irreversibles con git (`reset --hard`, `clean -f`, `push --force`, reescribir historia publicada, borrar ramas o stashes). Ante la duda, no tocar.
- Nunca pushear: el `push` lo hace el humano.
