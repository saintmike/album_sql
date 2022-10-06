-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.24-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for album
CREATE DATABASE IF NOT EXISTS `album` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `album`;

-- Dumping structure for table album.album
CREATE TABLE IF NOT EXISTS `album` (
  `id_album` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre_album` varchar(100) NOT NULL,
  PRIMARY KEY (`id_album`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table album.categorias
CREATE TABLE IF NOT EXISTS `categorias` (
  `id_categoria` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre_categoria` varchar(100) NOT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table album.documento
CREATE TABLE IF NOT EXISTS `documento` (
  `id_documento` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_album` int(10) unsigned NOT NULL,
  `id_categoria` int(10) unsigned NOT NULL,
  `descripcion_categoria` varchar(1000) DEFAULT NULL,
  KEY `documento_fk_idx` (`id_documento`),
  KEY `album_fk_idx` (`id_album`),
  KEY `categorias_fk_idx` (`id_categoria`),
  CONSTRAINT `album_fk_idx` FOREIGN KEY (`id_album`) REFERENCES `album` (`id_album`) ON UPDATE CASCADE,
  CONSTRAINT `categorias_fk_idx` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for function album.FN_ValidarDato
DELIMITER //
CREATE FUNCTION `FN_ValidarDato`(p_cadena VARCHAR(100)) RETURNS tinyint(1)
BEGIN
  DECLARE aux_longitud INT;
  DECLARE aux_mensaje BOOL; 

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    RETURN FALSE;
  END;    

  SET aux_longitud = LENGTH(p_cadena);
  SET aux_mensaje = FALSE;
 
 	IF aux_longitud > 0 THEN
		SET aux_mensaje = true;
	ELSE
		SET aux_mensaje = false;
	END IF;

  RETURN aux_mensaje;

END//
DELIMITER ;

-- Dumping structure for table album.fotografia
CREATE TABLE IF NOT EXISTS `fotografia` (
  `id_fotografia` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_documento` int(10) unsigned NOT NULL,
  `nombre_fotografia` varchar(100) NOT NULL,
  `ruta_archivo` varchar(100) NOT NULL,
  `archivo_comprimido` longblob NOT NULL,
  `nombre_descripcion` varchar(100) NOT NULL,
  KEY `fotografia_fk_idx` (`id_fotografia`),
  KEY `documento_fk_idx` (`id_documento`),
  CONSTRAINT `documento_fk_idx` FOREIGN KEY (`id_documento`) REFERENCES `documento` (`id_documento`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table album.fotografia_detalle
CREATE TABLE IF NOT EXISTS `fotografia_detalle` (
  `id_fotografia_detalle` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_fotografia` int(10) unsigned NOT NULL,
  `version_fotografia` int(10) NOT NULL,
  `fecha_creacion` date DEFAULT current_timestamp(),
  `fecha_modificacion` date DEFAULT NULL,
  `extension_fotografia` varchar(100) NOT NULL,
  KEY `fotografia_detalle_fk_idx` (`id_fotografia_detalle`),
  KEY `fotografia_fk_idx1` (`id_fotografia`),
  CONSTRAINT `fotografia_fk_idx1` FOREIGN KEY (`id_fotografia`) REFERENCES `fotografia` (`id_fotografia`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table album.fotografia_logs
CREATE TABLE IF NOT EXISTS `fotografia_logs` (
  `id_fotografia_log` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_fotografia_detalle` int(10) unsigned NOT NULL,
  `tipo_modificafion` varchar(100) DEFAULT 'C' COMMENT 'C = Creacion, A = Actualizar, E = Eliminar',
  `tamaño_fotografia` varchar(100) DEFAULT NULL,
  KEY `fotografia_logs_fk_idx` (`id_fotografia_log`),
  KEY `fotografia_detalle_fk_idx` (`id_fotografia_detalle`),
  CONSTRAINT `fotografia_detalle_fk_idx` FOREIGN KEY (`id_fotografia_detalle`) REFERENCES `fotografia_detalle` (`id_fotografia_detalle`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for procedure album.SP_actualizarFoto
DELIMITER //
CREATE PROCEDURE `SP_actualizarFoto`(
		IN	v_nombre_album VARCHAR(500),
		IN	v_nombre_categoria VARCHAR(500),
		IN	v_nombre_fotografia VARCHAR(500),
		IN	v_ruta_fotografia VARCHAR(500),
		IN	v_archivo_comprimido LONGBLOB,
		IN	v_nombre_descripcion_fotografia VARCHAR(500),
		OUT v_estatus VARCHAR(100),
		OUT	v_nombre_descripcion VARCHAR(500)
)
begin
  
  DECLARE l_id_album int;
  DECLARE l_id_categoria int;
  DECLARE l_id_estatus int;
  DECLARE l_id_documento int;
  DECLARE l_id_fotografia int;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @vsqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET v_estatus = 'ERROR';
        SET v_nombre_descripcion = CONCAT('Error en SP_crearDocumento. ', @errno, " (", @vsqlstate, "): ", @text);
        ROLLBACK;
    END;
   
  START TRANSACTION;
 
 	IF FN_ValidarDato(v_nombre_album) AND 
 		FN_ValidarDato(v_nombre_categoria) AND 
 		FN_ValidarDato(v_nombre_fotografia) AND 
 		FN_ValidarDato(v_ruta_fotografia) AND
 		FN_ValidarDato(v_archivo_comprimido) AND
 		FN_ValidarDato(v_nombre_descripcion_fotografia) THEN
 		
 		SELECT id_album
	 	INTO l_id_album
	 	from album where nombre_album = v_nombre_album;
	 
	 	SELECT id_categoria 
	 	INTO l_id_categoria
	 	from categorias where nombre_categoria = v_nombre_categoria;
	 
	 	SELECT id_documento
	 	into l_id_documento
	 	from documento where id_album = l_id_album AND id_categoria = l_id_categoria;
	
		IF l_id_album > 0 AND l_id_categoria > 0 THEN
		
			IF l_id_documento > 0 THEN 
			
				SELECT id_fotografia 
			 	into l_id_fotografia
			 	from fotografia where nombre_fotografia = v_nombre_fotografia;
			 
			 UPDATE fotografia SET ruta_archivo = v_ruta_fotografia, archivo_comprimido = v_archivo_comprimido, nombre_descripcion = v_nombre_descripcion_fotografia
			 WHERE id_fotografia  = l_id_fotografia;
									
				SET l_id_estatus = LAST_INSERT_ID();
				
				IF l_id_estatus > 0 THEN
				
					UPDATE fotografia_detalle SET version_fotografia = (version_fotografia + 1), fecha_modificacion = NOW(), extension_fotografia = SUBSTRING_INDEX(v_nombre_fotografia, ".", -1)
					WHERE id_fotografia = l_id_estatus;
											
					SET l_id_estatus = LAST_INSERT_ID();
				
					IF l_id_estatus > 0 THEN

							UPDATE fotografia_logs SET tipo_modificacion = 'A', tamaño_fotografia = octet_length(v_archivo_comprimido)
							WHERE id_fotografia_detalle = l_id_estatus;
							
							SET l_id_estatus = LAST_INSERT_ID();
						
							 IF l_id_estatus > 0 THEN 
							  	SET v_estatus = 'SUCCESS';
								SET v_nombre_descripcion = 'Se actualizo la fotografia correctamente';
							  ELSE 
								SET v_estatus = 'ERROR';
								SET v_nombre_descripcion = 'Ocurrió un error al actualizar la información';
							  END IF;
							 
					ELSE
						SET v_estatus = 'ERROR';
						SET v_nombre_descripcion = 'Ocurrio un error al actualizar la información';
						ROLLBACK;
					END IF;
				
				
				ELSE
				  	SET v_estatus = 'ERROR';
					SET v_nombre_descripcion = 'Ocurrio un error al actualizar la información';
					ROLLBACK;
				END IF;
							
			ELSE 
				SET v_estatus = 'ERROR';
				SET v_nombre_descripcion = 'No se encontró la relacion de album con la categoria';
			END IF;
			
	 	ELSE
	 		SET v_estatus = 'ERROR';
			SET v_nombre_descripcion = 'No se encontró el album o la categoria';
		END IF;
 	ELSE 
 		SET v_estatus = 'ERROR';
		SET v_nombre_descripcion = 'Ocurrió un error, uno o mas campos vienen vacios';
 	END IF;
 
   COMMIT;
  
end//
DELIMITER ;

-- Dumping structure for procedure album.SP_CrearAlbum
DELIMITER //
CREATE PROCEDURE `SP_CrearAlbum`(
		IN	nombre_album VARCHAR(500),
		OUT estatus VARCHAR(100),
		OUT	nombre_descripcion VARCHAR(500)
)
begin
  
  DECLARE l_id_estatus int;
  DECLARE l_validacion bool;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @vsqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET estatus = 'ERROR';
        SET nombre_descripcion = CONCAT('Error en SP_CrearAlbum. ', @errno, " (", @vsqlstate, "): ", @text);
        ROLLBACK;
    END;
   
  START TRANSACTION;
 
  SET l_validacion = FN_ValidarDato(nombre_album);
  
  IF l_validacion THEN
  
  	INSERT INTO album (nombre_album) values (nombre_album);
  	
  	SET l_id_estatus = LAST_INSERT_ID();
 
	  IF l_id_estatus > 0 THEN 
	  	SET estatus = 'SUCCESS';
		SET nombre_descripcion = 'Se guardó el album correctamente';
	  ELSE 
		SET estatus = 'ERROR';
		SET nombre_descripcion = 'Ocurrió un error';
	  END IF;
  
  ELSE
  		SET estatus = 'ERROR';
		SET nombre_descripcion = 'Ocurrió un error, no se detecto un nombre de album';
  END IF;
	
   COMMIT;
end//
DELIMITER ;

-- Dumping structure for procedure album.SP_crearDocumento
DELIMITER //
CREATE PROCEDURE `SP_crearDocumento`(
		IN	v_nombre_album VARCHAR(500),
		IN	v_nombre_categoria VARCHAR(500),
		IN	v_nombre_documento VARCHAR(500),
		OUT v_estatus VARCHAR(100),
		OUT	v_nombre_descripcion VARCHAR(500)
)
begin
  
  DECLARE l_id_album int;
  DECLARE l_id_categoria int;
  DECLARE l_id_estatus int;
  DECLARE l_aux_validacion_texto bool;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @vsqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET v_estatus = 'ERROR';
        SET v_nombre_descripcion = CONCAT('Error en SP_crearDocumento. ', @errno, " (", @vsqlstate, "): ", @text);
        ROLLBACK;
    END;
   
  START TRANSACTION;
 
 	IF FN_ValidarDato(v_nombre_album) AND FN_ValidarDato(v_nombre_album) AND FN_ValidarDato(v_nombre_album) THEN
 	
 		SELECT id_album
	 	INTO l_id_album
	 	from album where nombre_album = v_nombre_album;
	 
	 	SELECT id_categoria 
	 	INTO l_id_categoria
	 	from categorias where nombre_categoria = v_nombre_categoria;
	 
	 	INSERT INTO documento (id_album, id_categoria, descripcion_categoria) values (l_id_album, l_id_categoria, v_nombre_documento);
	  	
	  	SET l_id_estatus = LAST_INSERT_ID();
	 
		  IF l_id_estatus > 0 THEN 
		  	SET v_estatus = 'SUCCESS';
			SET v_nombre_descripcion = 'Se guardó el album correctamente';
		  ELSE 
			SET v_estatus = 'ERROR';
			SET v_nombre_descripcion = 'Ocurrió un error';
		  END IF;
	 
 	ELSE 
 		SET v_estatus = 'ERROR';
		SET v_nombre_descripcion = 'Ocurrió un error, uno o mas campos vienen vacios';
 	END IF;
	
   COMMIT;
  
end//
DELIMITER ;

-- Dumping structure for procedure album.SP_crearFoto
DELIMITER //
CREATE PROCEDURE `SP_crearFoto`(
		IN	v_nombre_album VARCHAR(500),
		IN	v_nombre_categoria VARCHAR(500),
		IN	v_nombre_fotografia VARCHAR(500),
		IN	v_ruta_fotografia VARCHAR(500),
		IN	v_archivo_comprimido LONGBLOB,
		IN	v_nombre_descripcion_fotografia VARCHAR(500),
		OUT v_estatus VARCHAR(100),
		OUT	v_nombre_descripcion VARCHAR(500)
)
begin
  
  DECLARE l_id_album int;
  DECLARE l_id_categoria int;
  DECLARE l_id_estatus int;
  DECLARE l_id_documento int;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @vsqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET v_estatus = 'ERROR';
        SET v_nombre_descripcion = CONCAT('Error en SP_crearDocumento. ', @errno, " (", @vsqlstate, "): ", @text);
        ROLLBACK;
    END;
   
  START TRANSACTION;
 
 	IF FN_ValidarDato(v_nombre_album) AND 
 		FN_ValidarDato(v_nombre_categoria) AND 
 		FN_ValidarDato(v_nombre_fotografia) AND 
 		FN_ValidarDato(v_ruta_fotografia) AND
 		FN_ValidarDato(v_archivo_comprimido) AND
 		FN_ValidarDato(v_nombre_descripcion_fotografia) THEN
 		
 		SELECT id_album
	 	INTO l_id_album
	 	from album where nombre_album = v_nombre_album;
	 
	 	SELECT id_categoria 
	 	INTO l_id_categoria
	 	from categorias where nombre_categoria = v_nombre_categoria;
	 
	 	SELECT id_documento
	 	into l_id_documento
	 	from documento where id_album = l_id_album AND id_categoria = l_id_categoria;
	
		IF l_id_album > 0 AND l_id_categoria > 0 THEN
		
			IF l_id_documento > 0 THEN 
			
				INSERT INTO fotografia (id_documento, nombre_fotografia, ruta_archivo, archivo_comprimido, nombre_descripcion) VALUES 
										(l_id_documento, v_nombre_fotografia, v_ruta_fotografia, v_archivo_comprimido, v_nombre_descripcion_fotografia);
									
				SET l_id_estatus = LAST_INSERT_ID();
				
				IF l_id_estatus > 0 THEN
				
					INSERT INTO fotografia_detalle (id_fotografia, version_fotografia, fecha_modificacion, extension_fotografia) VALUES 
												(l_id_estatus, 1, NOW(), SUBSTRING_INDEX(v_nombre_fotografia, ".", -1)); 
											
					SET l_id_estatus = LAST_INSERT_ID();
				
					IF l_id_estatus > 0 THEN

							INSERT INTO fotografia_logs (id_fotografia_detalle, tipo_modificacion, tamaño_fotografia) VALUES 
												(l_id_estatus, 'C', octet_length(v_archivo_comprimido)); 
							
							SET l_id_estatus = LAST_INSERT_ID();
						
							 IF l_id_estatus > 0 THEN 
							  	SET v_estatus = 'SUCCESS';
								SET v_nombre_descripcion = 'Se guardó la fotografia correctamente';
							  ELSE 
								SET v_estatus = 'ERROR';
								SET v_nombre_descripcion = 'Ocurrió un error al guardar la información';
							  END IF;
							 
					ELSE
						SET v_estatus = 'ERROR';
						SET v_nombre_descripcion = 'Ocurrio un error al guardar la información';
						ROLLBACK;
					END IF;
				
				
				ELSE
				  	SET v_estatus = 'ERROR';
					SET v_nombre_descripcion = 'Ocurrio un error al guardar la información';
					ROLLBACK;
				END IF;
							
			ELSE 
				SET v_estatus = 'ERROR';
				SET v_nombre_descripcion = 'No se encontró la relacion de album con la categoria';
			END IF;
			
	 	ELSE
	 		SET v_estatus = 'ERROR';
			SET v_nombre_descripcion = 'No se encontró el album o la categoria';
		END IF;
 	ELSE 
 		SET v_estatus = 'ERROR';
		SET v_nombre_descripcion = 'Ocurrió un error, uno o mas campos vienen vacios';
 	END IF;
 
   COMMIT;
  
end//
DELIMITER ;

-- Dumping structure for procedure album.SP_eliminarFoto
DELIMITER //
CREATE PROCEDURE `SP_eliminarFoto`(
		IN	v_nombre_album VARCHAR(500),
		IN	v_nombre_categoria VARCHAR(500),
		IN	v_nombre_fotografia VARCHAR(500),
		IN	v_ruta_fotografia VARCHAR(500),
		IN	v_archivo_comprimido LONGBLOB,
		IN	v_nombre_descripcion_fotografia VARCHAR(500),
		OUT v_estatus VARCHAR(100),
		OUT	v_nombre_descripcion VARCHAR(500)
)
begin
  
  DECLARE l_id_album int;
  DECLARE l_id_categoria int;
  DECLARE l_id_estatus int;
  DECLARE l_id_documento int;
  DECLARE l_id_fotografia int;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @vsqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET v_estatus = 'ERROR';
        SET v_nombre_descripcion = CONCAT('Error en SP_crearDocumento. ', @errno, " (", @vsqlstate, "): ", @text);
        ROLLBACK;
    END;
   
  START TRANSACTION;
 
 	IF FN_ValidarDato(v_nombre_album) AND 
 		FN_ValidarDato(v_nombre_categoria) AND 
 		FN_ValidarDato(v_nombre_fotografia) AND 
 		FN_ValidarDato(v_ruta_fotografia) AND
 		FN_ValidarDato(v_archivo_comprimido) AND
 		FN_ValidarDato(v_nombre_descripcion_fotografia) THEN
 		
 		SELECT id_album
	 	INTO l_id_album
	 	from album where nombre_album = v_nombre_album;
	 
	 	SELECT id_categoria 
	 	INTO l_id_categoria
	 	from categorias where nombre_categoria = v_nombre_categoria;
	 
	 	SELECT id_documento
	 	into l_id_documento
	 	from documento where id_album = l_id_album AND id_categoria = l_id_categoria;
	
		IF l_id_album > 0 AND l_id_categoria > 0 THEN
		
			IF l_id_documento > 0 THEN 
			
				SELECT id_fotografia 
			 	into l_id_fotografia
			 	from fotografia where nombre_fotografia = v_nombre_fotografia;
			 
			 	DELETE FROM fotografia WHERE id_fotografia  = l_id_fotografia;
				
				IF l_id_fotografia > 0 THEN
				
					DELETE FROM fotografia_detalle WHERE id_fotografia = l_id_fotografia;
				
					IF l_id_fotografia > 0 THEN

							UPDATE fotografia_logs SET tipo_modificacion = 'E'
							WHERE id_fotografia_detalle = l_id_estatus;
							
							SET l_id_estatus = LAST_INSERT_ID();
						
							 IF l_id_estatus > 0 THEN 
							  	SET v_estatus = 'SUCCESS';
								SET v_nombre_descripcion = 'Se elimino la fotografia correctamente';
							  ELSE 
								SET v_estatus = 'ERROR';
								SET v_nombre_descripcion = 'Ocurrió un error al eliminar la información';
							  END IF;
							 
					ELSE
						SET v_estatus = 'ERROR';
						SET v_nombre_descripcion = 'Ocurrio un error al eliminar la información';
						ROLLBACK;
					END IF;
				
				
				ELSE
				  	SET v_estatus = 'ERROR';
					SET v_nombre_descripcion = 'Ocurrio un error al eliminar la información';
					ROLLBACK;
				END IF;
							
			ELSE 
				SET v_estatus = 'ERROR';
				SET v_nombre_descripcion = 'No se encontró la relacion de album con la categoria';
			END IF;
			
	 	ELSE
	 		SET v_estatus = 'ERROR';
			SET v_nombre_descripcion = 'No se encontró el album o la categoria';
		END IF;
 	ELSE 
 		SET v_estatus = 'ERROR';
		SET v_nombre_descripcion = 'Ocurrió un error, uno o mas campos vienen vacios';
 	END IF;
 
   COMMIT;
  
end//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
