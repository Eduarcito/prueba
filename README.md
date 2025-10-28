# 🍞 Prueba – Panadería Web

**Tipo de proyecto:** Aplicación web en Java con Maven  
**Desarrollador:** Eduardo Iraheta  
**Lenguajes:** Java, CSS  

---

## 🔹 Descripción

Este proyecto es una **aplicación web para la gestión interna de una panadería**, diseñada para administrar productos, usuarios y ventas. La aplicación está desarrollada en **Java** con Maven, y cuenta con una interfaz web estilizada con **CSS**.

El objetivo es brindar un sistema sencillo pero funcional para la administración eficiente de una panadería, incluyendo panel de control, gestión de usuarios y manejo de transacciones.

---

## 🗂 Estructura del proyecto

prueba/
├─ src/
│ └─ main/
│ └─ webapp/ # Archivos web: HTML, JSP, CSS
├─ target/ # Archivos compilados por Maven
├─ pom.xml # Configuración de Maven y dependencias


- **Java (61.6%)**: Lógica de negocio y controladores  
- **CSS (38.4%)**: Diseño y estilo de la interfaz web  

---

## 🛠 Tecnologías utilizadas

- **Java 17**  
- **Maven**  
- **CSS**  
- **Azure Data Studio** (para gestión de base de datos SQL)  
- **Linux** como entorno de desarrollo  
- **Visual Studio Code** como editor principal  

---

## ⚙ Funcionalidades principales

- Gestión de **usuarios**: registro, edición y eliminación  
- Administración de **productos** de la panadería  
- Manejo de **ventas y transacciones**  
- **Panel de control** para visualización de información clave  

---

## 🚀 Cómo ejecutar el proyecto

1. Clonar el repositorio:  
```bash
git clone https://github.com/Eduarcito/prueba.git

Abrir el proyecto en Visual Studio Code o NetBeans

Ejecutar con Maven:
mvn clean install
mvn tomcat7:run   # si usas Tomcat

Abrir la aplicación en un navegador:

http://localhost:8080/prueba
