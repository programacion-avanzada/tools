# pa-tools

Visualizaciones interactivas para enseñar Programación Avanzada. Cada visualización es un único archivo `.html` autocontenido: sin build, sin instalación, se abre en el navegador o se sirve como archivo estático.

[`index.html`](index.html) es la portada: lista todas las herramientas agrupadas por tema. Al agregar una herramienta nueva, sumarla ahí además de en la tabla de abajo (ver checklist en [AGENTS.md](AGENTS.md)).

## Visualizaciones disponibles

### Programación Dinámica

| Archivo | Tema | Complejidad |
|---|---|---|
| [`dp/knapsack.html`](dp/knapsack.html) | Mochila 0/1 | O(n·W) |
| [`dp/lcs.html`](dp/lcs.html) | Subsecuencia Común más Larga (LCS) | O(m·n) |
| [`dp/edit-distance.html`](dp/edit-distance.html) | Distancia de Edición (Levenshtein) | O(m·n) |

Todas permiten:
- Editar los datos de entrada (cadenas, capacidad, elementos, costos) y resolver.
- Ver la tabla de PD completa.
- Hacer clic en cualquier celda para ver, paso a paso, la fórmula de recurrencia y la sustitución numérica que produjo ese valor, con las celdas de las que depende resaltadas por color.
- Ver el resultado final (valor óptimo / LCS / distancia mínima) y la reconstrucción de la solución (objetos elegidos / subsecuencia / secuencia de operaciones).
- Cambiar entre modo claro y oscuro (botón 🌙/☀️ en la barra superior, se recuerda entre visitas).
- Autoguardado en el navegador (localStorage): la configuración queda como estaba al volver a abrir la herramienta.
- Botón "🆕 Nuevo": vuelve a los valores de ejemplo (con confirmación de 2 pasos).
- Botón "🔗 Compartir": copia un link con la configuración actual (cadenas, capacidad, elementos, costos) codificada en la URL — al abrirlo la carga directo, sin backend.

### Recursión

| Archivo | Tema |
|---|---|
| [`recursion/call-tree.html`](recursion/call-tree.html) | Árbol de Llamadas Recursivas (DAG) |

Permite:
- Construir progresivamente el árbol de llamadas de una función recursiva (ej. Fibonacci): crear el nodo raíz y agregarle hijos, con el layout equilibrado recalculándose solo. Cada hijo nuevo arranca con la misma etiqueta que su padre (lista para sobreescribir si hace falta otra).
- Editar la etiqueta de cualquier nodo, y borrar un nodo junto con todo su subárbol (con confirmación de 2 pasos).
- Conectar dos nodos existentes con una flecha extra curva (DAG) para marcar que representan el mismo subproblema (memoización) — la flecha se puede seleccionar y quitar con un clic sin afectar los nodos.
- Bandas horizontales por nivel de profundidad, cada una con degradado de color y etiquetada con el número de nivel y la cantidad de nodos en ese nivel; el total de nodos del diagrama se ve en un badge de la barra superior.
- Pan y zoom libres, con un botón para reajustar la vista a todo el diagrama.
- Una caja de texto opcional (arriba a la derecha) para escribir en LaTeX la ecuación de recurrencia que se está graficando (ej. `T(n) = T(n-1) + T(n-2)`), renderizada con KaTeX.
- Botón "🆕 Nuevo": borra todo el diagrama para empezar de cero (con confirmación de 2 pasos).
- Autoguardado en el navegador (localStorage) y modo claro/oscuro, igual que el resto de las herramientas.
- Botón "🔗 Compartir": copia un link que incluye todo el diagrama (árbol, flechas y ecuación) codificado en la URL — al abrirlo carga ese diagrama directamente, sin backend ni servidor intermedio.

### Grafos

| Archivo | Tema | Complejidad |
|---|---|---|
| [`grafos/editor.html`](grafos/editor.html) | Editor de Grafos (dibujar y exportar) | — |
| [`grafos/dfs.html`](grafos/dfs.html) | DFS — Recorrido en Profundidad (pila explícita) | O(V+E) |
| [`grafos/bfs.html`](grafos/bfs.html) | BFS — Recorrido en Anchura (cola + array de distancias) | O(V+E) |
| [`grafos/dijkstra.html`](grafos/dijkstra.html) | Dijkstra — Caminos Mínimos (cola de prioridad) | O((V+E)·log V) |
| [`grafos/prim.html`](grafos/prim.html) | Prim — Árbol de Expansión Mínima (cola de prioridad de aristas) | O(E·log E) |

DFS, BFS, Dijkstra y Prim permiten:
- Cargar cualquier grafo no dirigido escribiendo su lista de aristas (`A-B`, una por línea o separadas por coma; un token sin guion declara un nodo aislado); el orden de las aristas define el orden de exploración de los vecinos.
- Elegir el nodo inicial con un selector, y recorrer el algoritmo paso a paso (manual, con autoplay a velocidad ajustable, o reiniciando la animación sin perder el grafo cargado).
- Ver en todo momento la estructura de datos del algoritmo (pila en DFS, cola + array de distancias en BFS), el pseudocódigo con la línea actual resaltada, y una explicación en lenguaje llano de cada paso.
- Distinguir por color los nodos no visitados / pendientes / actual / ya procesados, y las aristas de árbol (llevaron a un nodo nuevo) de las descartadas (llevan a uno ya visitado) — clasificación que queda fija una vez que la arista se examina. BFS además muestra la distancia (en saltos) desde el nodo inicial junto a cada nodo descubierto.
- Arrastrar los nodos para destrabar cruces de aristas.

Dijkstra además:
- Acepta aristas con peso (`A-B:3`; sin peso vale 1, los pesos negativos se rechazan) y se puede alternar entre grafo dirigido y no dirigido.
- Muestra siempre la matriz de adyacencia, los arrays de distancias (D) y predecesores (P), y la cola de prioridad (con las entradas viejas tachadas, que se descartan al extraerlas).
- Arma paso a paso la tabla de seguimiento clásica (Iteración | S | V − S | w | D[x]/P[x]), agregando una fila por cada nodo que pasa a S y resaltando los valores que cambian.
- Plantea con KaTeX, en cada relajación, `D[w] = min(D[w], D[v] + C(v,w))` con los valores sustituidos.
- Autoguardado en el navegador (localStorage), modo claro/oscuro, botón "🆕 Nuevo" y "🔗 Compartir" (grafo + posiciones + nodo inicial codificados en la URL), igual que el resto de las herramientas.

Prim además:
- Grafo no dirigido con pesos (`A-B:3`; sin peso vale 1, se admiten pesos negativos).
- Cola de prioridad de aristas `(peso, u, v)` sin actualización de prioridades: las entradas cuyo `v` ya está en el MST se ven tachadas y se descartan al extraerlas.
- Tabla de seguimiento (Iteración | V | V_MST | Arista seleccionada | Peso | W), con las aristas descartadas como filas tachadas; lista de aristas del MST y peso total W siempre a la vista.
- Aristas del MST en verde, descartadas punteadas. Si el grafo no es conexo, lo avisa y devuelve el árbol de la componente del vértice inicial.

El editor de grafos no ejecuta ningún algoritmo: solo dibuja.
- Mismo formato de texto (`A-B` o `A-B:costo`, el costo es texto libre y opcional), dirigido o no dirigido, nodos arrastrables con las aristas siguiéndolos en vivo.
- Paleta de colores Dracula: con un color elegido, cada clic en un nodo lo pinta (el texto pasa a claro u oscuro según el fondo); volver a clickear el color apaga el modo pintar, y ✖ quita el color.
- Mismo mecanismo para las aristas: se elige un tipo de línea (normal, punteada o de guiones) y cada clic en una arista le cambia el trazo.
- Panel ocultable con la matriz de adyacencia (botón "🧮 Matriz"): con pesos si alguna arista tiene costo (sin arista = ∞, arista sin costo = 1), si no booleana (`true`/`false`, como para Warshall). Si el grafo es no dirigido, queda espejada. Filas y columnas en orden numérico o lexicográfico, igual que en Dijkstra.
- Exporta a SVG o PNG con fondo transparente y un margen de 1em, descargando o copiando al portapapeles. Los colores son los del tema actual.
- Exporta a PPTX (PowerPoint / Google Slides): una diapositiva 16:9 con figuras nativas editables. Las aristas son conectores enganchados a los nodos (al mover un nodo en la presentación, sus aristas lo siguen); los costos son cuadros de texto sueltos que no se mueven solos.
- Exporta también a DOT (Graphviz) con colores, tipos de línea, costos como `label` y la posición actual de cada nodo (`pos`, la respetan `neato -n`/`fdp`; `dot` arma su propio layout).
- "🔗 Compartir" incluye el texto del grafo, si es dirigido, los colores de los nodos y los tipos de línea (no las posiciones: al abrir el link se usa el layout circular). El autoguardado local sí recuerda las posiciones.

## Cómo usarlas

Abrir el `.html` directamente en el navegador, o servirlas localmente:

```bash
make serve   # sirve el directorio en http://localhost:4000 (PORT=xxxx para cambiar el puerto)
```

## Stack técnico (vía CDN, sin build)

- **Bootstrap 5.3.3** — layout y componentes UI.
- **Vue 3** (`vue.global.js`, Composition API) — estado reactivo e interacción.
- **KaTeX 0.16.10** — renderizado de fórmulas matemáticas.
- **PptxGenJS 4.0.1** — solo en `grafos/editor.html`, para el export a PPTX (se carga al exportar, no al abrir la página).
- **Canvas 2D** — dibujo imperativo del diagrama en `recursion/call-tree.html` y `grafos/` (salvo `grafos/editor.html`, que dibuja en SVG para poder exportarlo).

Ver [AGENTS.md](AGENTS.md) para la convención/plantilla que siguen estos archivos y las guías para crear visualizaciones nuevas.
