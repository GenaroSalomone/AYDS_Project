# Aplicación de trivias

*Materias: Análisis y Diseño de Sistemas e Ingeniería de Software.*

*Integrantes: Genaro Salomone - Cristian Herrera*

**Para levantar la app deberás realizar los siguientes pasos:**

Ubicado en el directorio AYDS_Project,

1. Instalar las gemas o dependencias:

bundle install

2. Crear la base de datos de desarrollo:

bundle exec rake db:migrate

_Con docker:_
...


3. Cargar en la base de datos de desarrollo las preguntas y respuestas:

bundle exec rake db:seed

_Con docker:_
...


4. levantar la aplicación:

bundle exec rackup -p 3000

_Con docker:_
...

5. Una vez levantada dirigirse a:

[localhost:3000](https://localhost:3000)

---

**Para testear la aplicación deberás realizar los siguientes pasos:**

1. Crear la base de datos de test:

bundle exec rake db:migrate RACK_ENV=test

_Con docker:_
...


2. Setear la variable de ambiente en test y ejecutar pruebas:

_En windows:_

$env:RACK_ENV='test'

bundle exec rspec

__En Linux:_
...

