**Aplicación de trivias para Análisis y Diseño de Sistemas e Ingeniería de Software.**

*Integrantes: Genaro Salomone - Cristian Herrera*

**Para levantar la app deberás realizar los siguientes pasos:**

# Ubicado en el directorio AYDS_Project,

1. instalar las gemas o dependencias:

bundle install

2. crear la base de datos de desarrollo:

bundle exec rake db:migrate

_Conn docker:_
...


3. cargar en la base de datos de desarrollo las preguntas y respuestas:

bundle exec rake db:seed

_Con docker:_
...


4. levantar la aplicación y dirigirse a -> [Sitio web](https://localhost:3000)

bundle exec rackup -p 3000

_Con docker:_
...


**Para testear la aplicación deberás realizar los siguientes pasos:**

1. crear la base de datos de test:

bundle exec rake db:migrate RACK_ENV=test

_Con docker:_
...


2. setear la variable de ambiente en test y ejecutar pruebas:

*En windows:*

$env:RACK_ENV='test'

bundle exec rspec

*En Linux:*
...

