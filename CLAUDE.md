# CLAUDE.md

## Instrucciones para el asistente

No ejecutar ninguna acción de escritura de `git` ni `gh` (commit, push, crear/borrar branches, tags, releases, cambios de configuración del repo/Pages, etc.). Si hace falta alguna de estas acciones, indicar los comandos para que el usuario los corra a mano.

Guía para crear nuevas visualizaciones didácticas de Programación Avanzada en este proyecto. Hay dos familias:
- **Tablas de Programación Dinámica** (`dp/knapsack.html`, `dp/lcs.html`, `dp/edit-distance.html`): layout de 2 columnas, tabla HTML interactiva. Ver "Estructura de página" y "Convención de interacción con la tabla" abajo.
- **Diagramas en Canvas** (`recursion/call-tree.html`): layout full-bleed, dibujo imperativo en `<canvas>`. Ver "Familia 2: visualizaciones basadas en Canvas" abajo.

Las reglas de esta sección (stack, idioma) y las de **Modo claro/oscuro**, **Persistencia/"Nuevo"/Compartir por URL**, **Footer** y **Portada** aplican a **ambas familias**. Al crear una visualización nueva, copiar el archivo existente más parecido en forma (una tabla → `dp/lcs.html`; un diagrama/grafo → `recursion/call-tree.html`) y adaptar.

## Reglas duras

- **Un solo archivo `.html`, autocontenido.** Nada de build, nada de archivos separados de JS/CSS.
- **Todo vía CDN, con versión fijada** (no `@latest`):
  - Bootstrap `5.3.3` — **solo el CSS** (`bootstrap.min.css`). Ninguna visualización usa componentes JS de Bootstrap (modal, dropdown, tooltip, etc.), así que no se carga `bootstrap.bundle.min.js`. Si una visualización nueva necesita algún componente interactivo de Bootstrap (con `data-bs-*`), recién ahí sumar el bundle.
  - Vue `3` global build (`unpkg.com/vue@3/dist/vue.global.js`) — Composition API (`setup()`), no Options API. Destructurar de `Vue` solo lo que se use (`createApp, ref, computed, nextTick`, y `watch` únicamente si de verdad se usa).
  - KaTeX `0.16.10` (CSS + `katex.min.js`) desde `cdn.jsdelivr.net`. **No cargar `katex/contrib/auto-render.min.js`** — nunca se usa `renderMathInElement`, el render es siempre manual con `katex.render()` (ver más abajo).
- **Bootstrap lo más plano posible**: componentes estándar (`navbar`, `card`, `table`, `badge`, `list-group`, `btn`), sin JS custom de Bootstrap (no modals, no tooltips), sin utilidades exóticas. El único CSS custom es el necesario para las celdas interactivas de la tabla DP.
- **Idioma: español** (`lang="es"`), tanto la UI como los textos explicativos.
- **KaTeX se renderiza a mano** con `katex.render(...)` sobre `document.getElementById(...)`, dentro de una función `renderExplanation()` llamada después de `nextTick()`. No usar la directiva/auto-render de Vue para esto — mezclar el re-render reactivo de Vue con el DOM manual de KaTeX da problemas; por eso los tres archivos renderizan a mano en divs con id fijo (`formula-box`, `subst-box`).

## Estructura de página (seguir este layout)

```
<nav class="navbar navbar-dark bg-dark px-3">   → título con emoji + badge "DP · O(...)"
<div class="container-fluid py-3">
  <div class="row g-3">
    <!-- Columna izquierda: col-12 col-md-4 col-xl-3 -->
      - card "Parámetros"/"Cadenas de entrada" (inputs de datos)
      - (opcional) card de costos/configuración extra
      - botón "▶ Resolver" (btn-dark w-100)
      - card "Leyenda" (list-group, un badge de color por cada tipo de dependencia)
      - firma: <p> Hecho con ❤️ por <a href="https://github.com/programacion-avanzada">Programación Avanzada</a> (y <a href="https://claude.ai">Claude</a>)</p> (ver sección Footer)
    <!-- Columna derecha: col-12 col-md-8 col-xl-9 -->
      - estado vacío (antes de resolver): card centrada con emoji grande + instrucción
      - banner de resultado (card border-success): valor/resultado destacado + reconstrucción de la solución
      - card "Tabla de Programación Dinámica": tabla con thead table-dark, celdas .dp-cell clicleables
      - card "🔍 Explicación paso a paso": dos columnas (fórmula general | sustitución numérica), con badge de veredicto
```

## Convención de interacción con la tabla

- Cada celda tiene `class="dp-cell"` + una clase condicional según su rol (`cellClass(i, j)`):
  - `.cell-selected` (verde) — celda clickeada.
  - Una clase `.cell-dep-*` por cada celda de la que depende la recurrencia (diagonal, arriba, izquierda, etc.), cada una con su propio color, **el mismo color usado en el badge correspondiente de la Leyenda**.
- Paleta de colores por rol de dependencia (mantener consistente entre visualizaciones). **Usar siempre las variables CSS de Bootstrap, nunca hex fijo** — son las que cambian solas con el modo claro/oscuro (ver sección de tema más abajo):
  - Verde (`var(--bs-success-bg-subtle)` / `var(--bs-success-border-subtle)`) — celda seleccionada.
  - Amarillo (`var(--bs-warning-bg-subtle)` / `var(--bs-warning-border-subtle)`) — diagonal / coincidencia / "incluir".
  - Azul (`var(--bs-primary-bg-subtle)` / `var(--bs-primary-border-subtle)`) — arriba / "no incluir" / eliminar.
  - Rojo (`var(--bs-danger-bg-subtle)` / `var(--bs-danger-border-subtle)`) — izquierda / insertar.
  - Violeta (`var(--bs-purple-bg-subtle)` si existiera un cuarto rol realmente distinto — hoy ninguna visualización lo necesita). En `edit-distance.html` "sustituir" comparte la celda de origen (diagonal) con "igualar", así que usa el mismo amarillo — no le pongas un color propio a un caso que depende de la misma celda que otro.
  - Hover de celda: `var(--bs-tertiary-bg)`. Bordes de acento (ej. `.lcs-char`): `var(--bs-border-color)`.
- **Celdas de cabecera/índice** (fila de `<thead>` y columna de `<th>` con las etiquetas de fila, ej. "ε", "A", "B" en `lcs.html`/`edit-distance.html`): usar la clase `.dp-header-cell` (`background-color: var(--bs-secondary-bg-subtle) !important; color: var(--bs-emphasis-color) !important;`) — **nunca** `table-secondary text-dark`. Esa combinación se ve bien en modo claro pero rompe en oscuro: la celda hereda `color: white` del `thead.table-dark` ancestro (el `text-dark` de Bootstrap es un color fijo que no siempre gana esa pulseada de especificidad) y termina en texto claro sobre un fondo que Bootstrap sí oscureció — casi ilegible. `.dp-header-cell` fija ambos (fondo Y texto) con variables adaptativas, así se ve igual de bien en los dos temas. Las etiquetas chiquitas dentro de esas celdas (`i=`, `j=`) van con `text-muted` normal (ya queda legible una vez que el fondo de la celda es adaptativo, no fijo).
- Al hacer clic en una celda: `selectCell(i, j)` guarda la selección y llama `nextTick(() => renderExplanation(i, j))`, que rellena `#formula-box` (fórmula general con los índices concretos) y `#subst-box` (misma fórmula con los valores numéricos ya sustituidos, terminando en el resultado en negrita).
- Un computed `verdictBadge`/`verdictIcon`/`verdictText` resume en una frase + ícono + color qué rama de la recurrencia se tomó en esa celda.
- La solución se resuelve automáticamente al cargar (`nextTick(solve)`) y también mediante el botón "Resolver" tras editar los datos.

## Familia 2: visualizaciones basadas en Canvas (`recursion/`)

Para diagramas/grafos (árboles de llamadas, DAGs, y en general cualquier cosa que no sea una tabla 2D), en vez del layout de 2 columnas de la Familia 1. Referencia: `recursion/call-tree.html`.

- **Layout full-bleed**, no de 2 columnas: `#app` es un flex-column a `height:100vh` con tres hijos — navbar delgado, `.canvas-container` (`flex:1 1 auto; position:relative; overflow:hidden`) con el `<canvas>` a `width/height:100%`, y una `.footer-bar` al pie fuera del área del canvas. El footer (ver sección Footer) va ahí, no en una columna lateral que en este layout no existe.
- **Vue sí se usa** (Composition API, igual que la Familia 1) para todo el estado de la UI (nodos, selección, edición, cámara, panel de ecuación), pero **el dibujo es imperativo**: no hay ningún `watch`; cada función que muta estado llama `draw()` explícitamente al final. `reactive()` (además de `ref`) es válido para agrupar la cámara (`{offsetX, offsetY, scale}`).
- **`ref(null)` + `ref="nombre"` en el template** para acceder a los nodos DOM que hacen falta (`<canvas>`, el contenedor, un `<input>` flotante) — es el equivalente, para esta familia, del `document.getElementById` que usa la Familia 1 para las cajas de KaTeX.
- **KaTeX es opcional acá también**, pero cuando se usa (ej. una caja de "escribí la ecuación en LaTeX y se renderiza") sigue exactamente el mismo patrón manual (`katex.render(source, el, { throwOnError: false })`) que la Familia 1 — nunca `auto-render`.
- **Paleta de color por tema como objeto JS plano** (`PALETTES = { light: {...}, dark: {...} }`, elegido por `isDark.value`), no variables CSS de Bootstrap: `ctx.fillStyle` no puede resolver `var(--bs-*)`. Todo color que dibuje el canvas (fondo, nodos, aristas, texto, bandas) sale de esa paleta, nunca hex suelto en medio de `draw()`.
- **`devicePixelRatio` es obligatorio**: `canvas.width/height` en píxeles físicos (`clientWidth * dpr`), `ctx.setTransform(dpr,0,0,dpr,0,0)` para poder seguir dibujando en coordenadas CSS. Recalcular en cada resize de ventana.
- **Overlays HTML flotantes** (toolbar de acciones sobre un nodo/arista seleccionado, `<input>` de edición de etiqueta, panel de ecuación) van como elementos normales `position:absolute` dentro de `.canvas-container`, posicionados vía un `computed` que convierte coordenadas de mundo a pantalla con la transform de cámara vigente (`worldToScreen`). Nunca se dibuja texto editable ni controles dentro del canvas mismo.
- **Layout automático de árbol**: ancho de cada subárbol proporcional a su cantidad de hojas (Reingold-Tilford simplificado) — evita cruces en las aristas de árbol por construcción y centra a cada nodo sobre sus hijos. Profundidad → coordenada Y fija por nivel.
- **Cámara**: `fitToView()` recalcula automáticamente `scale`/`offset` tras cada cambio estructural, salvo que el usuario haya paneado/zoomeado a mano (`userAdjustedCamera`); un botón "Ajustar vista" la vuelve a activar. La cámara **no se persiste** entre sesiones — siempre arranca ajustada a lo guardado.
- **Aristas "extra" (no jerárquicas, ej. DAG)**: se dibujan como curva cuadrática (`ctx.quadraticCurveTo`), no como línea recta — así no atraviesan visualmente los nodos que puedan quedar en el medio del camino directo. El punto de control se calcula desplazando el punto medio en la perpendicular a la línea recta (`bow = distancia * 0.2`). El hit-testing (para poder seleccionar y borrar una arista con un clic) muestrea puntos sobre esa misma curva (`pointOnQuadratic`) y compara distancia a un umbral en píxeles — reusar la misma función de curva para dibujar e hit-testing, nunca recalcular la geometría dos veces por separado.
- **Selección**: nodos y aristas son selecciones mutuamente excluyentes (un solo `selectedId` de nodo o un solo `selectedEdgeId` de arista a la vez), cada una con su propio toolbar flotante. Clic en vacío o Escape limpia cualquier selección/modo activo (conectar, editar).
- **Persistencia/"Nuevo"/Compartir por URL**: ver la sección universal más abajo. Para esta familia, `currentState()` junta nodos + aristas + ecuación (nunca la cámara ni las selecciones — esas son transitorias y no se persisten), y `resetToDefault()` vacía todo el diagrama (no hay "valores de ejemplo" de un árbol).
- **Nodos nuevos heredan la etiqueta del padre**: `addChild(parentId)` copia `parent.label` como valor inicial del hijo (no un placeholder genérico) — como el hijo entra directo en modo edición con el texto seleccionado, alcanza con escribir encima si hace falta cambiarlo; y si el hijo representa la misma llamada que el padre en otra rama, ya queda bien por default.
- **Contadores de nodos**: cada banda de nivel muestra, debajo de "Nivel N", la cantidad de nodos en ese nivel (calculada una vez por `draw()` en un `countsByDepth`, no recalculada por nodo). El total del diagrama va en un badge del navbar (`🔢 N nodos`, oculto si no hay nodos), en el mismo lugar donde la Familia 1 muestra su badge de complejidad.

## Persistencia, "Nuevo" y Compartir por URL (obligatorio en toda página nueva)

Aplica a **ambas familias**. Toda herramienta con estado editable (inputs de una tabla, o nodos/aristas/ecuación de un diagrama) soporta las tres cosas de abajo, apoyadas en dos helpers idénticos por archivo:

```js
function encodeState(data) { return encodeURIComponent(JSON.stringify(data)); }
function decodeState(str) { return JSON.parse(decodeURIComponent(str)); }
```

Y en dos funciones propias de cada herramienta que **nunca deben repetir la lista de campos en más de un lugar**:
- `currentState()` — arma el objeto plano con todo el estado editable (nunca selección, cámara, u otro estado transitorio de UI).
- `applyState(data)` — vuelca ese objeto sobre los refs correspondientes, con fallback al valor actual si falta un campo (`data.campo ?? actual`).

1. **Autoguardado en localStorage.** Una key fija por herramienta (`pa-tools-<familia>-<nombre>`, ej. `pa-tools-dp-knapsack`, `pa-tools-recursion-call-tree`). `persist()` hace `localStorage.setItem(STORAGE_KEY, JSON.stringify(currentState()))`, y se dispara solo:
   - **Familia 1 (tabla):** con un `watch([...refs], persist)` sobre los refs de entrada (agregar `{ deep: true }` si alguno es un array/objeto mutado en profundidad, como `items`).
   - **Familia 2 (canvas):** explícito al final de cada función que muta estado (no hay `watch`, ver esa sección más abajo).

2. **Botón "🆕 Nuevo"** en el navbar (mismo grupo `d-flex` que el resto de los botones), con confirmación de 2 pasos — nunca `confirm()` nativo:
   ```js
   const newConfirm = ref(false); // o newTreeConfirm en recursion/call-tree.html
   function handleNewClick() {
     if (newConfirm.value) { resetToDefault(); return; }
     newConfirm.value = true;
     setTimeout(() => { if (newConfirm.value) newConfirm.value = false; }, 3000);
   }
   ```
   `resetToDefault()` vuelve a los valores de ejemplo hardcodeados de la herramienta (Familia 1) o vacía todo el diagrama (Familia 2 — un árbol nuevo empieza desde cero, no tiene "ejemplo").

3. **Botón "🔗 Compartir"**: arma la URL con el estado actual codificado en el **hash** (`#d=...`, nunca query string) y la copia:
   ```js
   const shareCopied = ref(false);
   function shareCurrentState() { // shareCurrentDiagram en recursion/call-tree.html
     const url = `${location.origin}${location.pathname}#d=${encodeState(currentState())}`;
     const onCopied = () => { shareCopied.value = true; setTimeout(() => { shareCopied.value = false; }, 2000); };
     if (navigator.clipboard?.writeText) {
       navigator.clipboard.writeText(url).then(onCopied).catch(() => window.prompt('Copiá el link:', url));
     } else {
       window.prompt('Copiá el link:', url);
     }
   }
   ```
   Al montar, `loadInitialState()` decide entre URL y localStorage — **la URL gana si está presente**, y de paso queda guardada como el estado "actual":
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
     loadFromStorage(); // lee localStorage con el mismo try/catch silencioso ante datos corruptos
   }
   ```

Sin compresión ni librerías — a la escala de estas herramientas (decenas de nodos/celdas) el JSON entra cómodo en una URL; si algún día hiciera falta comprimir, recién ahí evaluarlo.

## Modo claro/oscuro (obligatorio en toda página nueva)

Usa el mecanismo **nativo** de Bootstrap 5.3 (`data-bs-theme` en `<html>`), no una librería ni un tema custom. Tres piezas, siempre las tres:

1. **Script de inicialización en el `<head>`, antes del `<link>` de Bootstrap**, para fijar el tema antes del primer pintado (evita parpadeo) y respetar preferencia guardada o del sistema:
   ```html
   <script>
     (function () {
       const stored = localStorage.getItem('theme');
       const theme = stored || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
       document.documentElement.setAttribute('data-bs-theme', theme);
     })();
   </script>
   ```
2. **`<body>` sin `class="bg-light"`** (ni ningún `bg-*`/`text-*` fijo sobre el body). Bootstrap ya pinta el fondo/color del body vía variables CSS que responden a `data-bs-theme`; un `bg-light` fijo lo rompe.
3. **Botón de toggle en el navbar**, agrupado junto al badge de complejidad en un `div.d-flex` (si se agregan más elementos al navbar, van en el mismo grupo — el `<nav>` usa `justify-content: space-between` con dos hijos: marca a la izquierda, grupo a la derecha):
   ```html
   <div class="d-flex align-items-center gap-2">
     <span class="badge bg-secondary">DP · O(n·W)</span>
     <button class="btn btn-sm btn-outline-light" @click="toggleTheme" :title="isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'">{{ isDark ? '☀️' : '🌙' }}</button>
   </div>
   ```
   Lógica en `setup()` (agregar `isDark, toggleTheme` al `return`):
   ```js
   const isDark = ref(document.documentElement.getAttribute('data-bs-theme') === 'dark');
   function toggleTheme() {
     isDark.value = !isDark.value;
     const theme = isDark.value ? 'dark' : 'light';
     document.documentElement.setAttribute('data-bs-theme', theme);
     localStorage.setItem('theme', theme);
   }
   ```
   Si la página **no usa Vue** (como `index.html`), el mismo botón se resuelve con un `id` fijo (`theme-toggle-btn`) y JS vanilla equivalente (`addEventListener('click', ...)` + sincronizar el emoji) — ver `index.html` como referencia.

- **No mezclar** el botón dentro del `<div id="app">` con `<script>` sueltos ahí adentro: como Vue compila el `innerHTML` de `#app` como template, cualquier `<script>` insertado ahí no se re-ejecuta al montar. El toggle va bindeado por Vue (`@click`) si está dentro de `#app`, o vive fuera de `#app` si es vanilla.
- Todas las cajas/celdas con color (tabla DP, cajas de fórmula) deben usar las variables `--bs-*-subtle` de Bootstrap (ver paleta arriba) en vez de hex fijo — es lo que hace que el modo oscuro se vea bien sin CSS duplicado por tema. Las cajas de KaTeX (`#formula-box`, `#subst-box`) usan `bg-body-tertiary` (no `bg-white`), así el texto siempre contrasta con el fondo en ambos temas.
- Chips que muestran texto crudo de entrada (ej. `<span class="badge bg-light text-dark border">A: {{ strA }}</span>`) se dejan como están — es un chip de "código", legible en cualquier tema a propósito, no hace falta que seas adaptativo ahí.

## Footer (obligatorio, idéntico en toda página — incluida la portada)

Toda visualización y `index.html` terminan con esta firma, textual, sin clase CSS (nunca tuvo estilo propio, es solo texto):

```html
<p> Hecho con ❤️ por <a href="https://github.com/programacion-avanzada">Programación Avanzada</a> (y <a href="https://claude.ai">Claude</a>)</p>
```

En las visualizaciones va al final de la columna izquierda, dentro de un `<div class="mt-4 mb-4">`. En `index.html` va al final del `<div class="container">`, dentro de un `<div class="mt-5 mb-3">`. No cambiar el texto, el orden de los links, ni agregar iconos.

## Portada (`index.html`)

Es la única página sin Vue ni KaTeX — es un listado estático, no necesita reactividad. Mismo `<head>` (script de tema + Bootstrap CSS únicamente), mismo navbar (marca a la izquierda, grupo con el botón de tema a la derecha), tarjetas `card` con el emoji + nombre + badge descriptivo de cada herramienta, agrupadas por sección (`<h2 class="h5">` — "Programación Dinámica", "Recursión", y las que se agreguen), y el footer de arriba al final. Una sección nueva (una familia nueva de herramientas) es solo otro `<h2>` + `.row` más; no hace falta nada especial por ser Canvas en vez de tabla.

**Cada vez que se agregue una visualización nueva, actualizar `index.html`** con una tarjeta nueva (mismo emoji que usa esa visualización en su propio navbar) además de la fila en `README.md`.

## Checklist para una visualización nueva (Familia 1: tabla de PD)

Para un diagrama/grafo en Canvas (Familia 2), seguir en cambio la sección "Familia 2" de arriba y copiar `recursion/call-tree.html`; los pasos 5 y 7 de abajo (footer/tema y actualizar README/index) aplican igual.

1. Copiar cualquiera de los tres archivos existentes como plantilla (las tres están alineadas al mismo patrón: toggle de tema, autoguardado, "Nuevo" y compartir por URL incluidos).
2. Cambiar: `<title>`, texto del navbar (emoji + nombre + badge de complejidad), inputs de la columna izquierda, y la lógica de `solve()`.
3. Definir la paleta de `.cell-dep-*` según cuántas dependencias **distintas** tiene la recurrencia (no una por operación si dos operaciones comparten la misma celda de origen), usando las variables `--bs-*-bg-subtle`/`--bs-*-border-subtle` de la tabla de arriba (nunca hex fijo, se rompe en modo oscuro).
4. Escribir `renderExplanation()`: fórmula general en LaTeX (con `\begin{cases}`) + sustitución numérica paso a paso.
5. Mantener el footer idéntico (ver sección Footer arriba) y el botón/lógica de tema idénticos (ver sección Modo claro/oscuro arriba).
6. Actualizar `currentState()`/`applyState()` con los campos de entrada propios de esta herramienta — de ahí sale gratis el autoguardado, "Nuevo" y compartir por URL (ver esa sección arriba); `resetToDefault()` vuelve a los valores de ejemplo hardcodeados.
7. Antes de dar por terminada la visualización, revisar que no queden imports (`<script>`/`<link>`), clases CSS, variables o funciones sin usar — cada nueva visualización arranca copiando una plantilla ya sin peso muerto, no lo reintroduzcas.
8. Actualizar `README.md` (fila nueva en la tabla) y `index.html` (tarjeta nueva).

## Limpieza ya aplicada (no reintroducir)

Al auditar las tres visualizaciones se encontró y sacó código muerto — señales de qué evitar al copiar/pegar entre archivos:
- `bootstrap.bundle.min.js` cargado en los tres sin usarse (ningún `data-bs-*`, ninguna llamada a `bootstrap.*`) → se dejó solo el CSS de Bootstrap.
- `katex/contrib/auto-render.min.js` cargado en `knapsack.html` sin invocar `renderMathInElement` en ningún lado → eliminado.
- `watch` destructurado de `Vue` en `knapsack.html` sin usarse → eliminado del destructure.
- `.cell-dep-rep` definida en el CSS de `edit-distance.html` pero nunca asignada por `cellClass()` (la diagonal cubre igualar y sustituir con el mismo color) → eliminada la regla CSS, y de paso se corrigió `verdictBadge` que devolvía `bg-purple` (clase inexistente, ni de Bootstrap ni definida en el archivo) en vez de `bg-warning text-dark`.
- Clase `class="signature"` en la firma del pie, sin ninguna regla CSS que la defina en ningún archivo → quitada de las tres (el texto se ve igual).
- `table-secondary text-dark` en las celdas de cabecera/índice de `lcs.html` y `edit-distance.html`: se veía bien en modo claro pero en oscuro el texto quedaba blanco (heredado del `thead.table-dark` ancestro) sobre un fondo que sí se oscurecía — casi ilegible. Reemplazado por `.dp-header-cell` (ver "Convención de interacción con la tabla" arriba), que fija fondo y texto con variables adaptativas y se ve igual que antes en modo claro.
