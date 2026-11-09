# CHORD PLOTS DE PACIENTES: UN ARCHIVO EXCEL
# Guarde este archivo .R en la carpeta de la base y ejecutelo completo.
# Ruta ya configurada para el computador indicado por la usuaria.
# Lee la tabla dinamica original; NO escribe en el archivo Excel.
# No genera ni imputa datos. Cada enlace usa una celda departamento-ano.
# Los totales de la tabla dinamica se verifican, sin graficarlos otra vez.
# La suma de pacientes de varios anos/departamentos no representa personas
# unicas durante todo el periodo.
# Documentacion: https://jokergoo.github.io/circlize_book/book/the-chorddiagram-function.html

carpeta <- "C:/Users/ACER/Desktop/CODIGO R CORDH PLOT"

# Nombre EXACTO del archivo a procesar (configure aqui el archivo a analizar).
configuracion <- data.frame(
  archivo = "Heat patients.xlsx",
  hoja = "Hoja1",
  etiqueta = "Suma de heat patients",
  id = "general_calor",
  titulo = "Calor: personas (general)",
  stringsAsFactors = FALSE
)


fallar <- function(...) stop(paste0(...), call. = FALSE)

preparar_paquetes <- function() {
  paquetes <- c("readxl", "circlize")
  faltantes <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
  if (length(faltantes)) {
    message("Instalando paquetes necesarios: ", paste(faltantes, collapse = ", "))
    message("La primera instalacion requiere conexion a Internet.")
    tryCatch(
      utils::install.packages(faltantes, repos = "https://cloud.r-project.org"),
      error = function(e) fallar("No se pudieron instalar los paquetes: ", conditionMessage(e))
    )
  }
  faltantes <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
  if (length(faltantes)) {
    fallar("Faltan paquetes: ", paste(faltantes, collapse = ", "),
           ". Instalelos desde Tools > Install Packages y ejecute de nuevo.")
  }
}

crear_colores <- function(matriz_referencia) {
  # Paletas fijas, aproximadas a la imagen. Ningun color es aleatorio.
  paleta_departamentos <- c(
    "#18365F", "#15536B", "#087B88", "#009A9B", "#589A95", "#85877D",
    "#BA6457", "#E97850", "#F39324", "#F6B72E", "#D99A1C", "#B5802B",
    "#988A48", "#618F74", "#2D8E77", "#287B4D", "#547F35", "#827229",
    "#895F30", "#725F75", "#9154A4", "#A944BE", "#822DA5", "#6532A0",
    "#444B9B", "#5D72AE", "#78A5CC", "#A7CCD8", "#B3D7CC", "#D8CF9B",
    "#DFB4A5", "#D2A7C9", "#AB9DCC"
  )
  paleta_anos <- c(
    "#3B9D43", "#2BA56B", "#14A88A", "#00A4B7", "#008FC1",
    "#177BB5", "#295EB0", "#3E4CA8", "#5A3EAD", "#7431AD",
    "#8C24B0", "#60318E", "#3C3A78", "#15575D", "#2F703E"
  )
  orden <- order(-rowSums(matriz_referencia), rownames(matriz_referencia), method = "radix")
  departamentos <- rownames(matriz_referencia)[orden]
  if (length(departamentos) > length(paleta_departamentos)) {
    fallar("La base tiene mas departamentos que la paleta examinada. Revise la estructura.")
  }
  c(stats::setNames(paleta_departamentos[seq_along(departamentos)], departamentos),
    stats::setNames(paleta_anos, as.character(2010:2024)))
}

dibujar_chord <- function(m, titulo, letra, colores, panel = FALSE) {
  circlize::circos.clear()
  on.exit(circlize::circos.clear(), add = TRUE)
  if (sum(m) == 0) {
    graphics::plot.new()
    graphics::title(main = titulo)
    graphics::text(0.5, 0.5, "Todos los conteos de esta matriz son cero.")
    return(invisible(NULL))
  }
  # Un sector de total cero no ocupa superficie. La matriz CSV SI conserva
  # todas sus celdas originales, incluidos esos ceros.
  m <- m[rowSums(m) > 0, colSums(m) > 0, drop = FALSE]
  m <- m[order(-rowSums(m), rownames(m), method = "radix"),
         order(-colSums(m), colnames(m), method = "radix"), drop = FALSE]
  sectores <- c(rownames(m), colnames(m))
  if (anyNA(colores[sectores])) fallar("Falta un color para un sector de la matriz.")
  huecos <- stats::setNames(rep(2, length(sectores)), sectores)
  huecos[c(nrow(m), length(sectores))] <- 9
  circlize::circos.par(
    start.degree = 90, clock.wise = TRUE, gap.after = huecos,
    cell.padding = c(0, 0, 0, 0), track.margin = c(0.005, 0.005),
    canvas.xlim = c(-1.18, 1.18), canvas.ylim = c(-1.18, 1.18)
  )
  colores_enlaces <- matrix(
    rep(unname(colores[rownames(m)]), times = ncol(m)),
    nrow = nrow(m), ncol = ncol(m), dimnames = dimnames(m)
  )
  circlize::chordDiagram(
    x = m, order = sectores, grid.col = colores[sectores],
    col = colores_enlaces, transparency = 0.28,
    directional = 0, annotationTrack = "grid",
    annotationTrackHeight = circlize::mm_h(1.6),
    preAllocateTracks = list(track.height = circlize::mm_h(10)),
    link.border = NA, link.lwd = 0.2,
    link.sort = TRUE, link.decreasing = TRUE, link.largest.ontop = TRUE,
    reduce = 0, scale = FALSE
  )
  circlize::circos.trackPlotRegion(
    track.index = 1, bg.border = NA,
    panel.fun = function(x, y) {
      sector <- circlize::get.cell.meta.data("sector.index")
      centro <- circlize::get.cell.meta.data("xcenter")
      limite_y <- circlize::get.cell.meta.data("ylim")
      circlize::circos.text(
        x = centro, y = limite_y[1] + circlize::mm_y(1), labels = sector,
        facing = "clockwise", niceFacing = TRUE, adj = c(0, 0.5),
        cex = if (panel) 0.47 else 0.56, font = 2, col = "black"
      )
    }
  )
  graphics::title(main = titulo, cex.main = if (panel) 1.20 else 1.12,
                  font.main = 2, line = 0.5)
  graphics::mtext(letra, side = 3, adj = 0, line = 0.2, font = 2, cex = 1.2)
  invisible(NULL)
}

guardar_grafico <- function(ruta, formato, dibujar, panel = FALSE) {
  if (formato == "pdf") {
    grDevices::pdf(ruta, width = if (panel) 21 else 9,
                   height = if (panel) 14 else 9,
                   family = "serif", bg = "white", useDingbats = FALSE)
  } else {
    argumentos <- list(filename = ruta, width = if (panel) 6300 else 2700,
                       height = if (panel) 4200 else 2700, res = 300, bg = "white")
    if (isTRUE(capabilities("cairo"))) argumentos$type <- "cairo"
    do.call(grDevices::png, argumentos)
  }
  dispositivo <- grDevices::dev.cur()
  on.exit(grDevices::dev.off(which = dispositivo), add = TRUE)
  graphics::par(mfrow = if (panel) c(2, 3) else c(1, 1), cex = 1,
                mar = c(0.4, 0.5, 2.0, 0.5), family = "serif", xpd = NA)
  dibujar()
  invisible(ruta)
}


es_vacio <- function(x) is.na(x) | x == ""

leer_conteos <- function(x, contexto) {
  x <- as.character(x)
  invalidos <- which(is.na(x) | !grepl("^[0-9]+$", x))
  if (length(invalidos)) {
    fallar("Hay conteos vacios o no enteros en ", contexto,
           ". No se reemplazan por ceros ni se convierten separadores automaticamente.")
  }
  valores <- as.numeric(x)
  if (any(!is.finite(valores) | valores < 0 | valores > 2^53 - 1)) {
    fallar("Hay conteos fuera del rango numerico permitido en ", contexto, ".")
  }
  valores
}

leer_tabla_dinamica <- function(archivo, hoja, etiqueta_esperada) {
  if (!hoja %in% readxl::excel_sheets(archivo)) {
    fallar("Falta la hoja '", hoja, "' en ", basename(archivo), ".")
  }
  # Se ancla A1 para conservar la numeracion real de filas del Excel.
  # La lectura textual permite localizar los encabezados de la tabla
  # dinamica; solo se aceptan conteos enteros sin separadores ambiguos.
  bruto <- readxl::read_excel(
    archivo, sheet = hoja, col_names = FALSE, col_types = "text",
    range = readxl::cell_limits(c(1, 1), c(NA, NA)),
    trim_ws = FALSE, .name_repair = "minimal"
  )
  bruto <- as.matrix(bruto)
  if (!nrow(bruto) || ncol(bruto) < 17L) fallar("Tabla incompleta en ", basename(archivo), ".")
  cabecera <- which(bruto[, 1] == "Etiquetas de fila")
  if (length(cabecera) != 1L || cabecera < 2L || cabecera >= nrow(bruto)) {
    fallar("No se identifica una unica cabecera 'Etiquetas de fila' en ", basename(archivo), ".")
  }
  if (!etiqueta_esperada %in% bruto[seq_len(cabecera - 1L), 1]) {
    fallar("El contenido de ", basename(archivo), " no corresponde a '", etiqueta_esperada, "'.")
  }
  encabezados <- bruto[cabecera, ]
  anos <- as.character(2010:2024)
  columnas_anos <- match(anos, encabezados)
  if (anyNA(columnas_anos) || any(vapply(anos, function(a) sum(encabezados == a, na.rm = TRUE), integer(1)) != 1L)) {
    fallar("Se requieren columnas unicas para 2010-2024 en ", basename(archivo), ".")
  }
  columna_total <- which(encabezados == "Total general")
  if (length(columna_total) != 1L) fallar("No hay una unica columna Total general en ", basename(archivo), ".")
  posteriores <- seq.int(cabecera + 1L, nrow(bruto))
  fila_total <- posteriores[which(bruto[posteriores, 1] == "Total general")]
  if (length(fila_total) != 1L) fallar("No hay una unica fila Total general en ", basename(archivo), ".")
  columnas_extra <- setdiff(seq_len(ncol(bruto)), c(1L, columnas_anos, columna_total))
  if (length(columnas_extra)) {
    for (j in columnas_extra) {
      if ((!es_vacio(encabezados[j]) && encabezados[j] != "(en blanco)") ||
          any(!es_vacio(bruto[posteriores, j]))) {
        fallar("Hay una columna adicional con contenido no esperado en ", basename(archivo),
               ", columna ", j, ". No se excluira automaticamente.")
      }
    }
  }
  filas <- setdiff(posteriores, fila_total)
  conservar <- rep(TRUE, length(filas))
  for (i in seq_along(filas)) {
    f <- filas[i]
    nombre <- bruto[f, 1]
    if (es_vacio(nombre) || nombre == "(en blanco)") {
      if (any(!es_vacio(bruto[f, -1, drop = TRUE]))) {
        fallar("Hay una fila sin departamento con valores en ", basename(archivo),
               ", fila ", f, ". No se omitira.")
      }
      conservar[i] <- FALSE
    }
  }
  filas <- filas[conservar]
  departamentos <- bruto[filas, 1]
  if (length(departamentos) != 33L || anyDuplicated(departamentos) ||
      any(departamentos != trimws(departamentos))) {
    fallar("Se esperan los 33 departamentos/distrito de la tabla examinada, ",
           "con etiquetas unicas y sin espacios externos, en ", basename(archivo), ".")
  }
  valores <- leer_conteos(bruto[filas, columnas_anos, drop = FALSE], basename(archivo))
  matriz <- matrix(valores, nrow = length(filas), ncol = length(anos),
                   dimnames = list(departamentos, anos))
  totales_filas <- leer_conteos(bruto[filas, columna_total], paste0(basename(archivo), ": totales por departamento"))
  totales_anos <- leer_conteos(bruto[fila_total, columnas_anos], paste0(basename(archivo), ": totales anuales"))
  total_general <- leer_conteos(bruto[fila_total, columna_total], paste0(basename(archivo), ": total general"))
  if (any(rowSums(matriz) != totales_filas)) {
    fallar("Los totales por departamento no coinciden en ", basename(archivo), ". No se corrigieron datos.")
  }
  if (any(colSums(matriz) != totales_anos) || sum(matriz) != total_general) {
    fallar("Los totales anuales o el total general no coinciden en ", basename(archivo), ". No se corrigieron datos.")
  }
  list(matriz = matriz, total_excel = total_general, filas_excel = filas,
       columnas_excel = columnas_anos)
}


ejecutar_chord_plots <- function(carpeta) {
  if (!dir.exists(carpeta)) fallar("No existe la carpeta: ", carpeta, ". Revise la ruta.")
  archivos <- file.path(carpeta, configuracion$archivo)
  faltantes <- configuracion$archivo[!file.exists(archivos)]
  if (length(faltantes)) {
    fallar("Faltan estos archivos con sus nombres exactos: ", paste(faltantes, collapse = "; "))
  }
  preparar_paquetes()
  huellas <- unname(tools::md5sum(archivos))
  if (anyNA(huellas)) fallar("No se pudieron verificar los archivos originales.")
  on.exit({
    if (!identical(huellas, unname(tools::md5sum(archivos)))) {
      warning("El archivo Excel cambio durante la ejecucion. Revise si se guardo desde Excel.")
    }
  }, add = TRUE)
  tablas <- vector("list", nrow(configuracion))
  for (i in seq_along(tablas)) {
    message("Comprobando ", configuracion$archivo[i], " ...")
    tablas[[i]] <- leer_tabla_dinamica(archivos[i], configuracion$hoja[i], configuracion$etiqueta[i])
  }
  referencia <- tablas[[1]]$matriz
  for (i in seq_along(tablas)) {
    m <- tablas[[i]]$matriz
    if (!setequal(rownames(m), rownames(referencia)) || !identical(colnames(m), colnames(referencia))) {
      fallar("Los departamentos o anos difieren en ", configuracion$archivo[i], ".")
    }
  }
  colores <- crear_colores(referencia)
  base_salida <- file.path(carpeta, "resultados_chord_plots")
  if (!dir.exists(base_salida) && !dir.create(base_salida, recursive = TRUE)) {
    fallar("No se pudo crear la carpeta de resultados.")
  }
  nombre <- format(Sys.time(), "%Y%m%d_%H%M%S")
  salida <- file.path(base_salida, nombre)
  indice <- 1L
  while (file.exists(salida) || dir.exists(salida)) {
    indice <- indice + 1L
    salida <- file.path(base_salida, paste0(nombre, "_", indice))
  }
  if (!dir.create(salida)) fallar("No se pudo crear: ", salida)
  controles <- vector("list", length(tablas))
  for (i in seq_along(tablas)) {
    m <- tablas[[i]]$matriz
    id <- configuracion$id[i]
    message("Generando ", id, " ...")
    utils::write.csv2(m, file.path(salida, paste0(id, "_matriz.csv")),
                      row.names = TRUE, fileEncoding = "UTF-8")
    controles[[i]] <- data.frame(
      archivo = configuracion$archivo[i], hoja = configuracion$hoja[i],
      departamentos = nrow(m), anos = ncol(m), celdas = length(m),
      total_excel = tablas[[i]]$total_excel, total_matriz = sum(m),
      departamentos_con_total_cero = paste(rownames(m)[rowSums(m) == 0], collapse = "; "),
      anos_con_total_cero = paste(colnames(m)[colSums(m) == 0], collapse = "; "),
      stringsAsFactors = FALSE
    )
    for (formato in c("pdf", "png")) {
      guardar_grafico(file.path(salida, paste0(id, ".", formato)), formato,
                      dibujar = function() dibujar_chord(m, configuracion$titulo[i], LETTERS[i], colores))
    }
  }
  if (length(tablas) > 1) {
    for (formato in c("pdf", "png")) {
      guardar_grafico(file.path(salida, paste0("panel_6_pacientes.", formato)), formato,
                      panel = TRUE, dibujar = function() {
                        for (i in seq_along(tablas)) {
                          dibujar_chord(tablas[[i]]$matriz, configuracion$titulo[i], LETTERS[i], colores, panel = TRUE)
                        }
                      })
    }
  }
  control <- do.call(rbind, controles)
  utils::write.csv2(control, file.path(salida, "control_totales.csv"),
                    row.names = FALSE, fileEncoding = "UTF-8")
  utils::write.csv2(data.frame(sector = names(colores), color = unname(colores)),
                    file.path(salida, "colores.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  huellas_finales <- unname(tools::md5sum(archivos))
  if (!identical(huellas, huellas_finales)) {
    fallar("El archivo fuente cambio durante la ejecucion. Revise los archivos antes de usar los resultados.")
  }
  utils::write.csv2(data.frame(archivo = configuracion$archivo, md5_antes = huellas,
                               md5_despues = huellas_finales, sin_cambios = huellas == huellas_finales),
                    file.path(salida, "control_archivos.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  notas <- c(
    "CHORD PLOT DE PACIENTES, COLOMBIA, 2010-2024",
    paste("Ejecucion:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
    "Se leyo el archivo Excel original. No se escribio en el.",
    "Se verificaron los totales por departamento, anuales y generales de la tabla dinamica.",
    "El Total general se usa para control; no se suma como departamento ni como ano.",
    "Las filas/columnas (en blanco) se excluyen solo cuando estan completamente vacias.",
    "No se imputan celdas vacias ni se generan conteos. Los ceros proceden de la tabla original.",
    "Los sectores se ordenan por frecuencia descendente, en sentido horario.",
    "Se conserva un color por departamento con una paleta aproximada a la referencia.",
    "Un sector con total cero no tiene superficie en el dibujo y se conserva en el CSV.",
    "Cada grafico tiene su propia escala: los anchos describen las proporciones.",
    "Las sumas de pacientes de anos/departamentos distintos no son pacientes unicos de todo el periodo.",
    "", capture.output(utils::sessionInfo())
  )
  writeLines(enc2utf8(notas), file.path(salida, "LEEME.txt"), useBytes = TRUE)
  message("Listo: grafico individual en PDF y PNG.")
  message("El archivo Excel conserva su huella de verificacion.")
  message("Resultados: ", normalizePath(salida, winslash = "/", mustWork = TRUE))
  print(control[, c("archivo", "total_excel", "total_matriz")], row.names = FALSE)
  invisible(salida)
}

# EJECUCION AUTOMATICA AL CARGAR ESTE SCRIPT COMPLETO
resultado <- ejecutar_chord_plots(carpeta)