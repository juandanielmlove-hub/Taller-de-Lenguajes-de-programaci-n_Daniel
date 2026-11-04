-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 04-11-2026 a las 18:47:50
-- Versión del servidor: 10.4.32-MariaDB-log
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `juego_online_daniel`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_jugador_seguro` (IN `p_nombre_usuario` VARCHAR(50))   BEGIN
    SELECT
        jugador_id,
        nombre_usuario,
        nivel,
        monedas
    FROM jugadores
    WHERE nombre_usuario = p_nombre_usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `comprar_item_unico` (IN `p_jugador_id` INT, IN `p_item_id` INT, OUT `p_resultado` VARCHAR(255))   BEGIN
    DECLARE v_vendido BOOLEAN;
    DECLARE v_precio INT;
    DECLARE v_monedas INT;

    START TRANSACTION;

    SELECT vendido, precio_monedas
    INTO v_vendido, v_precio
    FROM items
    WHERE item_id = p_item_id
      AND es_unico = TRUE
    FOR UPDATE;

    IF v_vendido THEN
        SET p_resultado = 'RECHAZADO: el item único ya fue vendido a otro jugador.';
        ROLLBACK;
    ELSE
        SELECT monedas
        INTO v_monedas
        FROM jugadores
        WHERE jugador_id = p_jugador_id;

        IF v_monedas < v_precio THEN
            SET p_resultado = 'RECHAZADO: monedas insuficientes.';
            ROLLBACK;
        ELSE
            UPDATE items
            SET vendido = TRUE
            WHERE item_id = p_item_id;

            UPDATE jugadores
            SET monedas = monedas - v_precio
            WHERE jugador_id = p_jugador_id;

            INSERT INTO inventario_items (jugador_id, item_id, cantidad)
            VALUES (p_jugador_id, p_item_id, 1)
            ON DUPLICATE KEY UPDATE cantidad = cantidad + 1;

            SET p_resultado = CONCAT(
                'EXITO: item unico vendido al jugador ',
                p_jugador_id
            );

            COMMIT;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `subir_nivel_jugador` (IN `p_jugador_id` INT, IN `p_experiencia_ganada` INT)   BEGIN
    DECLARE v_experiencia_total INT;
    DECLARE v_niveles_ganados INT;

    SELECT experiencia + p_experiencia_ganada
    INTO v_experiencia_total
    FROM Jugadores
    WHERE jugador_id = p_jugador_id;

    IF v_experiencia_total IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Jugador no existe';
    END IF;

    SET v_niveles_ganados = FLOOR(v_experiencia_total / 500);

    UPDATE Jugadores
    SET nivel = nivel + v_niveles_ganados,
        experiencia = MOD(v_experiencia_total, 500)
    WHERE jugador_id = p_jugador_id;

    SELECT
        nivel AS nuevo_nivel,
        experiencia AS experiencia_restante
    FROM Jugadores
    WHERE jugador_id = p_jugador_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario_items`
--

CREATE TABLE `inventario_items` (
  `inventario_id` int(11) NOT NULL,
  `jugador_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `fecha_obtencion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inventario_items`
--

INSERT INTO `inventario_items` (`inventario_id`, `jugador_id`, `item_id`, `cantidad`, `fecha_obtencion`) VALUES
(1, 1, 1, 1, '2026-10-27 12:09:02'),
(2, 1, 3, 5, '2026-10-27 12:09:02'),
(3, 2, 4, 1, '2026-10-27 12:09:02'),
(4, 3, 1, 1, '2026-10-27 12:09:02'),
(5, 3, 2, 1, '2026-10-27 12:09:02'),
(6, 5, 1, 1, '2026-10-30 15:38:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `items`
--

CREATE TABLE `items` (
  `item_id` int(11) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `tipo` varchar(30) NOT NULL,
  `rareza` varchar(20) NOT NULL DEFAULT 'comun',
  `precio_monedas` int(11) NOT NULL DEFAULT 0,
  `es_unico` tinyint(1) NOT NULL DEFAULT 0,
  `vendido` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `items`
--

INSERT INTO `items` (`item_id`, `nombre`, `tipo`, `rareza`, `precio_monedas`, `es_unico`, `vendido`) VALUES
(1, 'Skin Dragon Dorado', 'skin', 'legendaria', 2000, 1, 1),
(2, 'Espada de Hielo', 'arma', 'epica', 800, 0, 0),
(3, 'Poción de Vida x5', 'consumible', 'comun', 50, 0, 0),
(4, 'Skin Sombra Ninja', 'skin', 'rara', 500, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `juegos`
--

CREATE TABLE `juegos` (
  `juego_id` int(11) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `genero` varchar(40) DEFAULT NULL,
  `fecha_lanzamiento` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `juegos`
--

INSERT INTO `juegos` (`juego_id`, `nombre`, `genero`, `fecha_lanzamiento`) VALUES
(1, 'Battle Arena Online', 'Battle Royale', '2024-01-15'),
(2, 'Dungeon Legends', 'RPG', '2023-06-01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jugadores`
--

CREATE TABLE `jugadores` (
  `jugador_id` int(11) NOT NULL,
  `nombre_usuario` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `nivel` int(11) NOT NULL DEFAULT 1,
  `experiencia` int(11) NOT NULL DEFAULT 0,
  `monedas` int(11) NOT NULL DEFAULT 0,
  `region` varchar(20) NOT NULL DEFAULT 'AMERICA',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp(),
  `baneado` tinyint(1) NOT NULL DEFAULT 0
) ;

--
-- Volcado de datos para la tabla `jugadores`
--

INSERT INTO `jugadores` (`jugador_id`, `nombre_usuario`, `email`, `nivel`, `experiencia`, `monedas`, `region`, `fecha_registro`, `baneado`) VALUES
(1, 'DragonSlayer99', 'dragon99@game.com', 12, 340, 1500, 'AMERICA', '2026-10-27 12:09:02', 0),
(2, 'ShadowNinja', 'shadow@game.com', 8, 120, 900, 'AMERICA', '2026-10-27 12:09:02', 0),
(3, 'PixelQueen', 'pixel@game.com', 20, 980, 5000, 'EUROPA', '2026-10-27 12:09:02', 0),
(4, 'NoobMaster', 'noob@game.com', 3, 210, 50, 'EUROPA', '2026-10-27 12:09:02', 0),
(5, 'RocketFox', 'fox@game.com', 15, 600, 200, 'AMERICA', '2026-10-27 12:09:02', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `logros`
--

CREATE TABLE `logros` (
  `logro_id` int(11) NOT NULL,
  `jugador_id` int(11) NOT NULL,
  `nombre_logro` varchar(80) NOT NULL,
  `fecha_obtenido` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `logros`
--

INSERT INTO `logros` (`logro_id`, `jugador_id`, `nombre_logro`, `fecha_obtenido`) VALUES
(1, 3, 'Campeón Invicto', '2026-10-27 12:09:03'),
(2, 1, 'Coleccionista Legendario', '2026-10-27 12:09:03'),
(3, 5, 'Explorador de Mazmorras', '2026-10-27 12:09:03');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partidas`
--

CREATE TABLE `partidas` (
  `partida_id` int(11) NOT NULL,
  `jugador_id` int(11) NOT NULL,
  `juego_id` int(11) NOT NULL,
  `puntaje` int(11) NOT NULL DEFAULT 0,
  `duracion_seg` int(11) NOT NULL DEFAULT 0,
  `resultado` varchar(20) NOT NULL DEFAULT 'jugada',
  `fecha` datetime NOT NULL DEFAULT current_timestamp()
) ;

--
-- Volcado de datos para la tabla `partidas`
--

INSERT INTO `partidas` (`partida_id`, `jugador_id`, `juego_id`, `puntaje`, `duracion_seg`, `resultado`, `fecha`) VALUES
(1, 1, 1, 4500, 620, 'victoria', '2026-10-27 12:09:03'),
(2, 1, 1, 3100, 540, 'derrota', '2026-10-27 12:09:03'),
(3, 2, 1, 2800, 480, 'derrota', '2026-10-27 12:09:03'),
(4, 3, 2, 9800, 900, 'victoria', '2026-10-27 12:09:03'),
(5, 3, 1, 7600, 700, 'victoria', '2026-10-27 12:09:03'),
(6, 4, 1, 300, 120, 'derrota', '2026-10-27 12:09:03'),
(7, 5, 2, 5200, 660, 'victoria', '2026-10-27 12:09:03');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `inventario_items`
--
ALTER TABLE `inventario_items`
  ADD PRIMARY KEY (`inventario_id`),
  ADD UNIQUE KEY `uq_jugador_item` (`jugador_id`,`item_id`),
  ADD KEY `fk_inv_item` (`item_id`),
  ADD KEY `idx_inventario_jugador` (`jugador_id`);

--
-- Indices de la tabla `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`item_id`);

--
-- Indices de la tabla `juegos`
--
ALTER TABLE `juegos`
  ADD PRIMARY KEY (`juego_id`);

--
-- Indices de la tabla `jugadores`
--
ALTER TABLE `jugadores`
  ADD PRIMARY KEY (`jugador_id`),
  ADD UNIQUE KEY `nombre_usuario` (`nombre_usuario`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `logros`
--
ALTER TABLE `logros`
  ADD PRIMARY KEY (`logro_id`),
  ADD KEY `fk_logro_jugador` (`jugador_id`);

--
-- Indices de la tabla `partidas`
--
ALTER TABLE `partidas`
  ADD PRIMARY KEY (`partida_id`),
  ADD KEY `fk_partida_juego` (`juego_id`),
  ADD KEY `idx_partidas_jugador` (`jugador_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `inventario_items`
--
ALTER TABLE `inventario_items`
  MODIFY `inventario_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `items`
--
ALTER TABLE `items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `juegos`
--
ALTER TABLE `juegos`
  MODIFY `juego_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `jugadores`
--
ALTER TABLE `jugadores`
  MODIFY `jugador_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `logros`
--
ALTER TABLE `logros`
  MODIFY `logro_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `partidas`
--
ALTER TABLE `partidas`
  MODIFY `partida_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `inventario_items`
--
ALTER TABLE `inventario_items`
  ADD CONSTRAINT `fk_inv_item` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`),
  ADD CONSTRAINT `fk_inv_jugador` FOREIGN KEY (`jugador_id`) REFERENCES `jugadores` (`jugador_id`);

--
-- Filtros para la tabla `logros`
--
ALTER TABLE `logros`
  ADD CONSTRAINT `fk_logro_jugador` FOREIGN KEY (`jugador_id`) REFERENCES `jugadores` (`jugador_id`);

--
-- Filtros para la tabla `partidas`
--
ALTER TABLE `partidas`
  ADD CONSTRAINT `fk_partida_juego` FOREIGN KEY (`juego_id`) REFERENCES `juegos` (`juego_id`),
  ADD CONSTRAINT `fk_partida_jugador` FOREIGN KEY (`jugador_id`) REFERENCES `jugadores` (`jugador_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
