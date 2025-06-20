Feature: Test de API súper simple

  Background:
    * configure ssl = true
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com'

  @id:1 @CrearPersonajeV1
  Scenario: Crear un personaje
    * path '/testuser/api/characters'
    * def randomName = 'Nombre-' + java.util.UUID.randomUUID()
    * def datarequest = read('classpath:../data/service-bp-se-test/createCharacter.json')
    * set datarequest.name = randomName
    And request datarequest
    When method POST
    Then status 201
    * print response
    And def characterId = response.id
    And print 'Character IDs: ' + characterId
    And  match response.name == randomName

  @id:2 @ListarCaracteresV1
  Scenario: Listar todos los personajes
    Given path '/testuser/api/characters'

    When method GET
    Then status 200
    * print response
    And match each response.[*].id == '#? _ > 0'
    And def characterId = response[0].id
    And print 'Character IDs: ' + characterId
  And  match response[0].name != null
  And  match response[0] contains { id: '#number', name: '#string' }


  @id:3 @ListarCaracterresPorIdV1
  Scenario: Buscar personajes por ID Existente
    * call read("@ListarCaracteresV1")
    Given path '/testuser/api/characters/' + characterId
    When method GET
    Then status 200
    * print response

  @id:4 @ListarCaracterresPorIdNoDataV1
  Scenario: Buscar personaje por ID no existe
    Given path '/testuser/api/characters/' +'9999'
    When method GET
    Then status 404
    * print response


  @id:5 @CrearPersonajeYaExisteV1
  Scenario: Crear un personaje Ya Existe
    * path '/testuser/api/characters'
    Given def datarequest = read('classpath:../data/service-bp-se-test/createCharacter.json')
    And request datarequest
    When method POST
    Then status 400
    * print response

  @id:6 @CrearPersonajeInvalidosCaractereV1
  Scenario: Crear un personaje con caracteres inválidos
    * path '/testuser/api/characters'
    Given def datarequest = read('classpath:../data/service-bp-se-test/createCharacterValuesRequired.json')
    And request datarequest
    When method POST
    Then status 400
    * print response

  @id:7 @ActualizarPersonajeExitosV1
  Scenario: Actualizar un personaje  Exitoso
    * call read("@CrearPersonajeV1")
    * path '/testuser/api/characters/' +characterId
    Given def datarequest = read('classpath:../data/service-bp-se-test/updateCharacter.json')
    And request datarequest
    When method PUT
    Then status 200
    * print response
  And  match response.id == characterId
  And  match response.name == datarequest.name

  @id:8 @ActualizarPersonajeNoExiteV1
  Scenario: Actualizar un personaje  Inexistente
    * path '/testuser/api/characters/' +'9999'
    Given def datarequest = read('classpath:../data/service-bp-se-test/updateCharacter.json')
    And request datarequest
    When method PUT
    Then status 404
    * print response

  @id:9 @EliminarPersonajeExitosoV1
  Scenario: Eliminar un personaje  Exitoso
    * call read("@CrearPersonajeV1")
    * path '/testuser/api/characters/' + characterId
    When method DELETE
    Then status 204

  @id:10 @EliminarPersonajeNoExitosoV1
  Scenario: Eliminar un personaje  Inexistente
    * path '/testuser/api/characters/' +'999'
    When method DELETE
    Then status 404