# pa-tools

Visualizaciones interactivas para enseñar Programación Avanzada. Cada visualización es un único archivo `.html` autocontenido: sin build, sin instalación, se abre en el navegador o se sirve como archivo estático.

[`index.html`](index.html) es la portada: lista todas las herramientas agrupadas por tema. Al agregar una herramienta nueva, sumarla ahí además de en la tabla de abajo (ver checklist en [CLAUDE.md](CLAUDE.md)).

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

## Cómo usarlas

Abrir el `.html` directamente en el navegador, o servirlas localmente:

```bash
make serve   # sirve el directorio en http://localhost:4000 (PORT=xxxx para cambiar el puerto)
```

## Stack técnico (vía CDN, sin build)

- **Bootstrap 5.3.3** — layout y componentes UI.
- **Vue 3** (`vue.global.js`, Composition API) — estado reactivo e interacción.
- **KaTeX 0.16.10** — renderizado de fórmulas matemáticas.
- **Canvas 2D** — dibujo imperativo del diagrama en `recursion/call-tree.html`.

Ver [CLAUDE.md](CLAUDE.md) para la convención/plantilla que siguen estos archivos y las guías para crear visualizaciones nuevas.
