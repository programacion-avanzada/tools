# FEATURES.md

Catálogo de los features generales de las visualizaciones: qué ofrece cada uno, cuál es la implementación de referencia para copiar y qué herramientas lo tienen. [AGENTS.md](AGENTS.md) dice **cómo** se arma cada familia (layout, convenciones, reglas duras); este archivo dice **qué** debería tener una herramienta y dónde está hecho mejor.

Para una herramienta nueva: recorrer las secciones 1 y 2 y copiar de la referencia. Para mantener una existente: mirar su fila en la [tabla de cobertura](#4-cobertura) y la lista de [brechas](#5-brechas). Al sumar un feature a una herramienta (o uno nuevo al catálogo), actualizar la tabla.

## 1. Base: toda página

Los tienen las 20 herramientas (en `recursion/call-tree.html` con otros nombres: `newTreeConfirm`, `shareCurrentDiagram`).

| Feature | Qué es | Referencia |
|---|---|---|
| Tema claro/oscuro | Botón ☀️/🌙 en el navbar; script en el `<head>` antes del CSS para no parpadear; colores siempre con `var(--bs-*)` (en canvas, paleta JS `PALETTES`). | AGENTS.md, "Modo claro/oscuro" |
| Autoguardado | `currentState()` / `applyState()` + `localStorage` con key `pa-tools-<carpeta>-<nombre>`. Nunca guarda selección, cámara ni paso actual. | AGENTS.md, "Persistencia" |
| 🆕 Nuevo | Confirmación en 2 clics (`¿Seguro?`), sin `confirm()`. Vuelve al ejemplo por defecto. | ídem |
| 🔗 Compartir | Estado en el hash (`#d=...`); al abrir el link, la URL gana sobre `localStorage`. | ídem |
| Vuelta a la portada | El título del navbar es un link a `../index.html` con `←`. | AGENTS.md, "Portada" |
| Footer | Texto fijo, idéntico en todas. | AGENTS.md, "Footer" |
| Estado vacío | Card centrada con emoji grande + instrucción cuando no hay datos. | `grafos/dijkstra.html` (`.empty-state-overlay`) |
| Angosto | Bajo 768px las columnas pasan a una sola. | `grafos/dijkstra.html` (`@media`) |
| Ejemplo de la cátedra | El ejemplo por defecto es el de las diapositivas, para que la herramienta y la clase muestren los mismos números. | `grafos/floyd-warshall.html` (`DEFAULT_GRAPH_TEXT`, `DEFAULT_POSITIONS`) |

## 2. Herramientas de algoritmos

| Feature | Qué es | Referencia |
|---|---|---|
| Paso a paso precalculado | `computeSteps()` corre el algoritmo real una vez y guarda un snapshot por parada didáctica; navegar es mover un puntero (`currentStepIndex`), nunca re-ejecutar. Los snapshots pueden guardar referencias en vez de copias (`done` + `isFilled`). | `grafos/dijkstra.html`; `grafos/floyd-warshall.html` (sin copias) |
| Controles de reproducción | ⏮ ⏪ ▶️/⏸️ ⏩ en el navbar + slider de velocidad (`speedMs`, `setInterval`). ⏪/⏩ deshabilitados en los extremos. | `grafos/dijkstra.html` |
| Granularidad | Dos modos sobre el mismo array de pasos: fino (cada celda) y grueso (cada iteración). El modo grueso solo para en los pasos con `summary`, que además trae un resumen de la iteración, y resalta el bloque entero del bucle en el pseudocódigo. | `grafos/floyd-warshall.html` ("Por k" / "Por celda"); `dp/lcs.html` ("Por fila" / "Por celda") |
| Atajos de teclado | ← → avanzan y retroceden según el modo; Esc suelta la selección. Se ignoran dentro de `input`/`textarea`/`select`. | `grafos/floyd-warshall.html` (`onKeyDown`) |
| Saltos directos | Botones para ir al inicio de cada iteración, o historial clickeable de operaciones. | `grafos/floyd-warshall.html` (`kButtons`); `estructuras/heap.html` (historial) |
| Pseudocódigo con línea activa | Texto de la cátedra tal cual, línea por línea con `white-space: pre`; las activas en `--bs-warning-bg-subtle`. Las líneas agregadas por la herramienta (no son de la cátedra) van en verde con un `title` que lo explica. | `grafos/floyd-warshall.html` (líneas de Z); `estructuras/union-find.html` (`+`) |
| Veredicto del paso | Badge con ícono + color + frase en lenguaje llano de qué pasó y por qué. | `grafos/dijkstra.html` (`badge`) |
| Fórmula + sustitución | KaTeX manual: fórmula general con índices concretos y la misma con valores, terminando en el resultado en negrita. | `dp/lcs.html` (`#formula-box` / `#subst-box`) |
| Fórmula coloreada | Cada término de la fórmula lleva el mismo color que su celda (`\htmlClass` con la clase `.cell-*`, `trust` solo para ese comando y `strict: 'ignore'`), así la fórmula y la tabla se leen juntas. | `grafos/floyd-warshall.html` (`COLORED`) |
| Clic → foco fijado | Un clic en una celda o un nodo lo fija y la explicación pasa a ser sobre él; sin nada fijado, el foco sigue al paso actual. Se suelta con Esc, con ✕ o con otro clic. En los grafos en canvas, el clic se distingue del arrastre (menos de 4 px), el nodo lleva un anillo violeta, su columna se marca en las tablas (`.th-pinned`) y una card "📌 Nodo" dice su estado en el paso (`pinnedInfo`). | `grafos/floyd-warshall.html` (`focus`/`selected`); `bnb/tsp.html` (`pinnedId`); `grafos/dijkstra.html` (`pinned`) |
| Lectura del resultado | Al clickear, además de la fórmula, una interpretación en palabras ("para llegar de 2 a 1, paso por 3…"), con lo mismo resaltado en la tabla y en el grafo. | `grafos/floyd-warshall.html` (`interpret`) |
| Leyenda | Un ítem por color, con el mismo badge que en las tablas y el grafo. | todas las de algoritmos |
| Seguimiento / historial | Tabla que crece con los pasos (iteración, estructuras, valores) o historial de operaciones. | `grafos/dijkstra.html`; `estructuras/heap.html` |
| Complejidad desplegable | `<details>` "⏱️ Complejidad" con línea, veces y costo en KaTeX, y una nota en prosa. | AGENTS.md, "Complejidad desplegable" |
| Auto-chequeo | `console.assert` sobre el ejemplo por defecto al cargar (resultado final y algún paso clave), con valores calculados a mano o conocidos (no copiados de lo que da la herramienta), como única prueba. Si la tabla o el algoritmo vive dentro de `setup()`, sacarlo a una función suelta para poder chequearlo. | `grafos/floyd-warshall.html` (`selfCheck`); `dp/knapsack.html` (`knapsackTable`) |

## 3. Datos y vista

| Feature | Qué es | Referencia |
|---|---|---|
| Entrada por texto | Textarea (`A-B:3`, uno por línea o con comas) + botón "▶ Aplicar"; errores en un `alert` chico, sin autoguardar en cada tecla. | `grafos/dijkstra.html` |
| Orden de nodos | `sortLabels()`: numérico si todas las etiquetas son números, si no lexicográfico. | `grafos/dijkstra.html` |
| Dirigido / no dirigido | Botón en el navbar; en dirigido, las aristas de ida y vuelta se curvan para no taparse. | `grafos/dijkstra.html` |
| Grafo en canvas | Cámara con pan/zoom y `fitToView`, nodos arrastrables (posiciones persistidas), `devicePixelRatio`. | `grafos/dijkstra.html` |
| SVG en el template | Para exportar o animar con Vue; sin `viewBox` (el HTML lo pasa a minúscula). | `grafos/editor.html`; `bnb/subset-sum.html` |
| Medición del tamaño real | `ResizeObserver` sobre el contenedor (no `window.resize`) para redibujar o reacomodar. | `complejidad/comparador.html`; `grafos/dijkstra.html` |
| Tablas que se ajustan al ancho | Todo en `em` escalado por una variable CSS; se achica hasta un mínimo y, si no entra, cambia de disposición (fila → 2×2). Nunca scroll horizontal. | `grafos/floyd-warshall.html` (`fitMatrices`) |
| Valores en monoespaciada | Las tablas de valores usan `font-monospace` para que los números queden alineados; en tablas que mezclan números y frases, solo las columnas numéricas. | `grafos/floyd-warshall.html`; `bnb/tsp.html` (seguimiento) |
| Exportar | PNG/SVG (fondo transparente), PPTX, DOT. | `grafos/editor.html`; `recursion/call-tree.html` (PNG) |
| Deshacer | Pila de estados en `persist()`, Ctrl+Z. | `recursion/call-tree.html` |

## 4. Cobertura

Features de las secciones 2 y 3 que varían entre herramientas (las de la sección 1 las tienen todas). `·` = no lo tiene, sin decir si aplica: eso va en [Brechas](#5-brechas).

| Herramienta | Paso a paso | Autoplay | ← → | Pseudocódigo | Complejidad | Fórmula KaTeX | Clic → foco | Seguimiento | Esc | Auto-chequeo |
|---|---|---|---|---|---|---|---|---|---|---|
| `dp/knapsack.html` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ |
| `dp/lcs.html` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ |
| `dp/edit-distance.html` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ |
| `recursion/call-tree.html` | · | · | · | · | · | ✅ | · | · | ✅ | · |
| `recursion/teorema-maestro.html` | · | · | · | · | · | ✅ | · | · | · | · |
| `complejidad/comparador.html` | · | · | · | · | · | ✅ | · | · | · | · |
| `complejidad/big-o.html` | · | · | · | · | · | ✅ | · | · | · | · |
| `grafos/editor.html` | · | · | · | · | · | · | · | · | · | · |
| `grafos/dfs.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ |
| `grafos/bfs.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ |
| `grafos/dijkstra.html` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `grafos/prim.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| `grafos/kruskal.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| `grafos/coloreo.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| `grafos/floyd-warshall.html` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `estructuras/heap.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ | · | ✅ |
| `estructuras/union-find.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | · | ✅ | · | ✅ |
| `bnb/subset-sum.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| `bnb/knapsack.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| `bnb/tsp.html` | ✅ | ✅ | ✅ | ✅ | ✅ | · | ✅ | ✅ | ✅ | ✅ |

Granularidad y fórmula coloreada están en `grafos/floyd-warshall.html` y en las tres de PD ("Por fila" / "Por celda"); las tablas ajustadas al ancho, solo en Floyd · Warshall.

## 5. Brechas

Lo que falta donde sí aplicaría, de más a menos impacto en clase:

1. **Pseudocódigo de PD**: los de Mochila, LCS y Distancia de edición los escribió la herramienta, no son de la cátedra; reemplazarlos por los de las diapositivas cuando estén (cambiar `PSEUDOCODE` y `LINES`).
