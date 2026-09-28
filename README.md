# pa-tools

Visualizaciones interactivas para enseñar Programación Avanzada. Cada visualización es un único archivo `.html` autocontenido: sin build, sin instalación, se abre en el navegador o se sirve como archivo estático.

[`index.html`](index.html) es la portada: lista todas las herramientas agrupadas por tema. Al agregar una herramienta nueva, sumarla ahí además de en la tabla de abajo (ver checklist en [AGENTS.md](AGENTS.md)).

## Visualizaciones disponibles

### Complejidad computacional

| Archivo | Tema |
|---|---|
| [`complejidad/comparador.html`](complejidad/comparador.html) | Órdenes de complejidad: tabla, gráfico y tiempos estimados |
| [`complejidad/big-o.html`](complejidad/big-o.html) | Notación Big O: buscar c y n₀ para que T(n) ≤ c·g(n) |

El comparador de órdenes de complejidad permite:
- Ver la tabla clásica (1, log n, √n, n, n log n, n², n³, 2ⁿ, n!) con ejemplos de algoritmos, y marcar solo las funciones que se quieren comparar.
- Agregar funciones propias (`n^1.5`, `n*log(n)^2`, `3^n`...), evaluadas con un parser propio (nunca `eval`, porque viajan en el link de Compartir).
- Graficar las marcadas de n = 1 a un n máximo, en escala lineal (se ve cómo las que crecen rápido aplastan al resto) o logarítmica, con rótulos al final de cada línea y un tooltip con los valores al pasar el mouse.
- Calibrar el tiempo con una frase ("un algoritmo O(n) tarda 1 ms con N = 1000", que fija el costo por operación c = T/N) y ver, para cada función: cuánto tardaría con ese N, una tabla de tiempos para N = 10 … 10⁶, y el N más grande que se resuelve en 1 segundo, 1 minuto, 1 hora, 1 día o 1 año. Todo se calcula en logaritmos, así que 2ⁿ o n! con N = 10⁶ no desbordan.
- Botones para marcar comparaciones típicas de un clic: búsquedas, ordenamientos, polinomiales, fuerza bruta, todas o ninguna.
- Una constante por función (ej. 100·n log n contra 2·n²): el gráfico marca dónde se cruzan y explica desde qué n conviene cada una (las constantes deciden con n chico, el orden con n grande).
- "Con una computadora k veces más rápida": cuánto crece el N máximo de cada función (× k con n, × √k con n², apenas + log₂ k con 2ⁿ).
- Autoguardado, "🆕 Nuevo", "🔗 Compartir" y modo claro/oscuro como el resto.

El explorador de Big O permite:
- Cargar una T(n) cualquiera (polinomio o expresión con `log`, `sqrt`, `sin`, `cos`, `abs`, `!`...) y una g(n) candidata, y mover c (slider logarítmico) y n₀ para ver en vivo si c·g(n) queda por encima de T(n) desde n₀.
- Veredicto con la definición en KaTeX y la sustitución: ✅ se cumple (con c y n₀ concretos), ❌ primer n ≥ n₀ donde falla, o ⚠️ T(n)/g(n) crece sin cota (ninguna c alcanza: T ∉ O(g)). Se verifica numéricamente (todos los enteros hasta n₀ + 10.000 y una muestra hasta 10¹⁵) y lo aclara: es una comprobación, no una demostración.
- Botones que calculan la c mínima para el n₀ actual y el n₀ mínimo para la c actual.
- Gráfico de T(n) contra c·g(n) (zona n ≥ n₀ sombreada y tramos que fallan en rojo, como el dibujo de la teoría) o del cociente T(n)/g(n) contra la recta c; escala lineal o logarítmica. Las intersecciones entre las curvas se marcan con un punto y su n aproximado, y se listan debajo diciendo qué curva queda arriba desde ahí. Zoom con la rueda del mouse (centrado en el cursor), arrastrar para moverse y doble clic para volver a ver desde n = 0; el eje vertical se reajusta a lo que se ve.
- Demostración algebraica paso a paso cuando T(n) es un polinomio y g(n) = a·nᵏ, como en el pizarrón: desarrolla, descarta los términos negativos y acota cada término por nᵏ para n ≥ 1 (ej. (n+1)² = n² + 2n + 1 ≤ n² + 2n² + n² = 4n², o sea c = 4 y n₀ = 1). Si el grado de T es mayor, explica por qué no es O.
- Límite de T(n)/g(n) (exacto para polinomios, estimado si no) y qué significa: a una constante L → mismo orden, cota ajustada (sirve toda c > L); a 0 → cota válida pero holgada; a ∞ → T ∉ O(g).
- Tabla de "Demostración" como la de la diapositiva (c | n | T(n) | c·g(n), verde si se cumple y rojo si no) y ejemplos precargados, incluido uno que no es O.

### Recursión

| Archivo | Tema |
|---|---|
| [`recursion/call-tree.html`](recursion/call-tree.html) | Árbol de Llamadas Recursivas (DAG) |
| [`recursion/teorema-maestro.html`](recursion/teorema-maestro.html) | Teorema Maestro — T(n) = a·T(n/b) + O(n^c) |

Permite:
- Construir progresivamente el árbol de llamadas de una función recursiva (ej. Fibonacci): crear el nodo raíz y agregarle hijos, con el layout equilibrado recalculándose solo. Cada hijo nuevo arranca con la misma etiqueta que su padre (lista para sobreescribir si hace falta otra).
- Crecimiento rápido (🌿 en la barra del nodo): elegir cuántos niveles y cuántos hijos por nodo, y se generan todos de una vez debajo del nodo (2 niveles de 2 hijos = 2 + 4 = 6 nodos), con la etiqueta del padre.
- Editar la etiqueta de cualquier nodo, y borrar un nodo junto con todo su subárbol (con confirmación de 2 pasos).
- Conectar dos nodos existentes con una flecha extra curva (DAG) para marcar que representan el mismo subproblema (memoización) — la flecha se puede seleccionar y quitar con un clic sin afectar los nodos.
- Pintar nodos y cambiar el trazo de las flechas con la misma paleta (Dracula) y los mismos tipos de línea (normal, punteada, de guiones) que el editor de grafos: con un color o un trazo elegido, cada clic en un nodo o en una flecha (del árbol o extra) lo aplica; ✖ quita el color. Las flechas extra arrancan de guiones.
- Valor de retorno opcional por nodo (⤴️ en la barra del nodo), que se muestra en un segundo renglón (`→ 3`).
- "🔁 Repetidos": pinta del mismo color los nodos con la misma etiqueta (subproblemas repetidos, para motivar la memoización); mientras está activo, los colores pintados a mano no se muestran.
- "↩️ Deshacer" (o Ctrl+Z): vuelve atrás cualquier cambio del diagrama, incluido un crecimiento rápido entero.
- Exportar a PNG el árbol completo (no solo lo que se ve): "⬇️ PNG" con el fondo de niveles, o "⬇️ PNG sin fondo" con fondo transparente y solo el árbol con un margen de 1em. Los colores son los del tema actual.
- Bandas horizontales por nivel de profundidad, cada una con degradado de color y etiquetada con el número de nivel y la cantidad de nodos en ese nivel; el total de nodos del diagrama se ve en un badge de la barra superior.
- Pan y zoom libres, con un botón para reajustar la vista a todo el diagrama.
- Una caja de texto opcional (arriba a la derecha) para escribir en LaTeX la ecuación de recurrencia que se está graficando (ej. `T(n) = T(n-1) + T(n-2)`), renderizada con KaTeX.
- Botón "🆕 Nuevo": borra todo el diagrama para empezar de cero (con confirmación de 2 pasos).
- Autoguardado en el navegador (localStorage) y modo claro/oscuro, igual que el resto de las herramientas.
- Botón "🔗 Compartir": copia un link que incluye todo el diagrama (árbol, flechas y ecuación) codificado en la URL — al abrirlo carga ese diagrama directamente, sin backend ni servidor intermedio.

El Teorema Maestro analiza recurrencias por división T(n) = a·T(n/b) + O(n^c):
- Se cargan a, b y c (o se elige un ejemplo: búsqueda binaria, merge sort, Karatsuba, Strassen, etc.) y muestra Θ(...) con el caso que aplica: domina la raíz (a < b^c), todos los niveles pesan igual (a = b^c) o dominan las hojas (a > b^c).
- Desarrollo en KaTeX: el enunciado del teorema y la sustitución con los valores cargados (a vs b^c y su equivalente log_b a vs c).
- Tabla del árbol de recursión para un n concreto: por nivel, cantidad de nodos, tamaño, costo por nodo y costo del nivel, con la razón r = a/b^c entre niveles y el total T(n). Al lado, un gráfico de barras con el costo de cada nivel, resaltando el que domina.
- Autoguardado, "🆕 Nuevo", "🔗 Compartir" y modo claro/oscuro como el resto.

### Grafos

| Archivo | Tema | Complejidad |
|---|---|---|
| [`grafos/editor.html`](grafos/editor.html) | Editor de Grafos (dibujar y exportar) | — |
| [`grafos/dfs.html`](grafos/dfs.html) | DFS — Recorrido en Profundidad (pila explícita) | O(V+E) |
| [`grafos/bfs.html`](grafos/bfs.html) | BFS — Recorrido en Anchura (cola + array de distancias) | O(V+E) |
| [`grafos/dijkstra.html`](grafos/dijkstra.html) | Dijkstra — Caminos Mínimos (cola de prioridad) | O((V+E)·log V) |
| [`grafos/prim.html`](grafos/prim.html) | Prim — Árbol de Expansión Mínima (cola de prioridad de aristas) | O(E·log E) |
| [`grafos/kruskal.html`](grafos/kruskal.html) | Kruskal — Árbol de Expansión Mínima (cola de aristas + Union-Find) | O(E·log E) |
| [`grafos/union-find.html`](grafos/union-find.html) | Union-Find — Comparación de variantes (quick-find, quick-union, weighted, path halving) | — |

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

Kruskal además:
- Mismo formato de grafo con pesos que Prim, sin vértice inicial; a igual peso, las aristas se extraen en el orden en que se declararon.
- Cola de prioridad con todas las aristas a la vista: las ya extraídas quedan marcadas como aceptadas o tachadas (descartadas).
- Union-Find ingenuo (`union(u, v)`: `padre[find(v)] ← find(u)`) mostrado como vector `padre[]` y como bosque de padres, con el camino de cada `find` y el `padre[]` que cambia en cada `union` resaltados. En el grafo, los vértices de un mismo subárbol comparten color.
- Tabla de seguimiento (Iteración | Arista aᵢ | w(aᵢ) | find(u) / find(v) | Subárboles | W(MST)), con las aristas descartadas como filas tachadas. Si el grafo no es conexo, devuelve un bosque.

El comparador de Union-Find no dibuja grafos: corre la misma secuencia de operaciones sobre las 4 variantes de Sedgewick a la vez, en una grilla 2×2.
- Elementos `0..N−1` o con nombres alfanuméricos (ordenados; los que aparecen en las operaciones se agregan solos). Operaciones en vivo (`union(p, q)` / `find(p)` / `connected(p, q)` / `count()`) o como secuencia de texto (`4-3` = union, `?9` = find, `4?3` = connected, `#` = count); cada operación es un paso del historial, navegable como el resto de las herramientas.
- Cada variante muestra `id[]` (y `sz[]` en las weighted), su bosque, el camino que recorrió `find`, las celdas que cambiaron y una explicación de lo que hizo. `union(p, q)` sigue la convención del libro: `id[find(p)] ← find(q)`; en las weighted, el árbol más chico cuelga del más grande (si empatan, el de q cuelga del de p). La compresión es por *halving*: `id[p] ← id[id[p]]`.
- Pseudocódigo de `find`, `union`, `connected` y `count` de cada variante (count con el contador de Sedgewick, que `union` decrementa), con las líneas que cambian respecto de la variante anterior resaltadas.
- Tabla comparativa con los accesos a `id[]`/`sz[]` (última operación y acumulado) y la altura máxima del bosque de cada variante.

El editor de grafos no ejecuta ningún algoritmo: solo dibuja.
- Mismo formato de texto (`A-B` o `A-B:costo`, el costo es texto libre y opcional), dirigido o no dirigido, nodos arrastrables con las aristas siguiéndolos en vivo.
- Paleta de colores Dracula: con un color elegido, cada clic en un nodo lo pinta (el texto pasa a claro u oscuro según el fondo); volver a clickear el color apaga el modo pintar, y ✖ quita el color.
- Mismo mecanismo para las aristas: se elige un tipo de línea (normal, punteada o de guiones) y cada clic en una arista le cambia el trazo.
- Panel ocultable con la matriz de adyacencia (botón "🧮 Matriz"): con pesos si alguna arista tiene costo (sin arista = ∞, arista sin costo = 1), si no booleana (`true`/`false`, como para Warshall). Si el grafo es no dirigido, queda espejada. Filas y columnas en orden numérico o lexicográfico, igual que en Dijkstra.
- Exporta a SVG o PNG con fondo transparente y un margen de 1em, descargando o copiando al portapapeles. Los colores son los del tema actual.
- Exporta a PPTX (PowerPoint / Google Slides): una diapositiva 16:9 con figuras nativas editables. Las aristas son conectores enganchados a los nodos (al mover un nodo en la presentación, sus aristas lo siguen); los costos son cuadros de texto sueltos que no se mueven solos.
- Exporta también a DOT (Graphviz) con colores, tipos de línea, costos como `label` y la posición actual de cada nodo (`pos`, la respetan `neato -n`/`fdp`; `dot` arma su propio layout).
- "🔗 Compartir" incluye el texto del grafo, si es dirigido, los colores de los nodos y los tipos de línea (no las posiciones: al abrir el link se usa el layout circular). El autoguardado local sí recuerda las posiciones.

### Estructuras de datos

| Archivo | Tema | Complejidad |
|---|---|---|
| [`estructuras/heap.html`](estructuras/heap.html) | Heap de mínimo (arreglo con la posición 0 sin usar) | insertar/extraer O(log n) |

El heap permite:
- Insertar un valor, extraer el mínimo o consultarlo en vivo: cada operación se reproduce sola, paso a paso (cada comparación e intercambio de flotar/hundir), o se carga una secuencia entera como texto (`7, 5, 9, x, ?`: número = insertar, `x` = extraer, `?` = ver mínimo).
- Ver a la vez el árbol y el arreglo, con los mismos resaltados: el elemento que flota o se hunde, con quién se compara, el menor de los hijos, el par intercambiado y el mínimo extraído. En el árbol, los intercambios se ven como desplazamientos animados, y un círculo punteado marca dónde cae el próximo elemento.
- Seguir el pseudocódigo de la cátedra (InsertarHeap + flotarElemento, ExtraerMinimo + hundirElemento, VerMinimo) con la línea activa resaltada y una explicación de cada paso, incluida la llamada recursiva de hundirElemento en la que se está.
- La explicación de cada paso hace la cuenta de los índices (`padre(5) = ⌊5/2⌋ = 2`, `izq = 2·2 = 4`, `der = 2·2 + 1 = 5`), que es lo que simplifica dejar la posición 0 sin usar.
- Tocar un i en la tabla (o un nodo en el árbol) marca su padre y sus hijos en los dos lados, con la cuenta: `padre(5) = ⌊5/2⌋ = 2`, `hijoIzquierdo(5) = 10 (no existe todavía)`...
- Contador de intercambios y comparaciones de la operación en curso, al lado de la altura del heap ⌊log₂ n⌋: flotar y hundir hacen como mucho un intercambio por nivel, O(log n).
- Tira con los mínimos extraídos, en el orden en que salieron.
- Historial de operaciones clickeable, autoplay con velocidad ajustable, autoguardado, "🆕 Nuevo", "🔗 Compartir" y modo claro/oscuro como el resto.

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
