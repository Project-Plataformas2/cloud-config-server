
# **Cloud Config Server (Spring Cloud Config)**

### Curso: Plataformas II

### Proyecto desarrollado por:

* **Santiago Hernández Saavedra**
* **Sergio Fernando Flórez Sanabria**
---

#  1. Introducción

Este repositorio contiene el **servidor central de configuración** del ecosistema de microservicios del proyecto de comercio electrónico. Su objetivo es proporcionar archivos de configuración externos y versionados a cada microservicio mediante **Spring Cloud Config Server**, permitiendo:

* Centralización de configuraciones
* Versionado mediante Git
* Perfiles por entorno (dev, stage, prod)
* Configuración dinámica sin reconstruir imágenes
* Integración con Zipkin, bases de datos, Flyway y Eureka

Cada microservicio obtiene sus propiedades desde este servidor según su perfil activo, lo cual permite despliegues reproducibles y una administración independiente del código fuente.

---

#  2. Estructura del repositorio

Comandos utilizados para ver el contenido real:

```bash
sergio@Sergio:~/RepoCloud$ ls
cloud-config-server

sergio@Sergio:~/RepoCloud/cloud-config-server$ ls
API-GATEWAY-dev.yml
API-GATEWAY-prod.yml
API-GATEWAY-stage.yml
APPLICAION-dev.yml
APPLICAION-prod.yml
APPLICAION-stage.yml
FAVOURITE-SERVICE-dev.yml
FAVOURITE-SERVICE-prod.yml
FAVOURITE-SERVICE-stage.yml
ORDER-SERVICE-dev.yml
ORDER-SERVICE-prod.yml
ORDER-SERVICE-stage.yml
PAYMENT-SERVICE-dev.yml
PAYMENT-SERVICE-prod.yml
PAYMENT-SERVICE-stage.yml
PRODUCT-SERVICE-dev.yml
PRODUCT-SERVICE-prod.yml
PRODUCT-SERVICE-stage.yml
PROXY-CLIENT-dev.yml
PROXY-CLIENT-prod.yml
PROXY-CLIENT-stage.yml
SERVICE-DISCOVERY-dev.yml
SERVICE-DISCOVERY-prod.yml
SERVICE-DISCOVERY-stage.yml
SHIPPING-DISCOVERY-dev.yml
SHIPPING-DISCOVERY-prod.yml
SHIPPING-DISCOVERY-stage.yml
USER-SERVICE-dev.yml
USER-SERVICE-prod.yml
USER-SERVICE-stage.yml
convertir_mayusculas.sh
```

Cada archivo `.yml` corresponde a **un microservicio y un entorno específico**.

---

#  3. Funcionamiento del servidor de configuración

En los archivos se observa la siguiente estructura común:

###  Puerto del servicio (ejemplo: 9296, 8800, 8300…)

Cada microservicio tiene un puerto diferente dependiendo del perfil.

###  Integración con GitHub

El Cloud Config Server obtiene la configuración desde:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/Project-Plataformas2/cloud-config-server
          clone-on-start: true
```

Este repositorio actúa como **repositorio central de configuración**.

###  Integración con Zipkin (tracing)

Todos los dev-profiles incluyen:

```yaml
spring:
  zipkin:
    base-url: ${SPRING_ZIPKIN_BASE_URL:http://localhost:9411/}
```

En Kubernetes el valor es reemplazado por:

```env
SPRING_ZIPKIN_BASE_URL=http://zipkin:9411/
```

###  Integración con Resilience4j

Los archivos incluyen manejo de resiliencia:

```yaml
resilience4j:
  circuitbreaker:
    instances:
      cloudConfig:
        failure-rate-threshold: 50
        sliding-window-size: 10
```

###  Configuración de logging

Cada entorno define niveles de log diferentes:

* **dev → DEBUG**
* **stage → DEBUG o INFO según microservicio**
* **prod → INFO**

Algunos perfiles guardan logs en rutas como:

```yaml
logging:
  file:
    name: src/main/resources/script/prod_log.log
```

---

#  4. Perfiles disponibles

Cada microservicio tiene **tres perfiles**:

| Perfil  | Descripción                                             |
| ------- | ------------------------------------------------------- |
| `dev`   | Base de datos H2, logs detallados, Flyway deshabilitado |
| `stage` | MySQL, logs debug/info, Flyway habilitado               |
| `prod`  | MySQL, menos logs, Flyway habilitado                    |

---

#  5. Configuración de bases de datos

###  **Dev → H2 en memoria**

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:ecommerce_dev_db
```

###  **Stage y Prod → MySQL**

```yaml
spring:
  datasource:
    url: ${SPRING_DATASOURCE_URL:jdbc:mysql://localhost:3306/ecommerce_stage_db}
    username: ${SPRING_DATASOURCE_USERNAME:root}
```

En Kubernetes estos valores vienen del ConfigMap del Helm Chart.

---

# 6. Configuración de Service Discovery

Los archivos `SERVICE-DISCOVERY-*.yml` muestran:

```yaml
eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
```

Esto indica que el servicio Discovery (Eureka) no se registra a sí mismo, como es correcto.

---

#  7. Archivos por microservicio

Cada microservicio tiene su propio archivo por entorno:

Ejemplo para **API Gateway**:

* `API-GATEWAY-dev.yml`
* `API-GATEWAY-stage.yml`
* `API-GATEWAY-prod.yml`

Cada uno define:

* Puerto del servidor
* Configuración de logging
* Integración con Zipkin
* Base de datos (si aplica)
* Flyway
* Nivel de logs
* Configuración opcional específica

Este patrón se repite en todos los microservicios.

---

# 8. Script auxiliar

El repo incluye:

```
convertir_mayusculas.sh
```

Usado para convertir los nombres de los archivos en mayusculas, todo para agilizar los procesos.

