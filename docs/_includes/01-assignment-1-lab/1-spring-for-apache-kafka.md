The Spring for Apache Kafka (spring-kafka) project applies core Spring concepts to the development of Kafka-based messaging solutions. It provides a "template" as a high-level abstraction for sending messages. It also provides support for Message-driven POJOs with @KafkaListener annotations and a "listener container".

## Kafka Publisher

1. The `TrafficControlService/src/main/java/dapr/traffic/fines/KafkaConfig.java` file defines custom JsonSerializer class to be used for serializing objects for kafka publishing.

    ```java
    public JsonObjectSerializer() {
        super(customizedObjectMapper());
    }

    private static ObjectMapper customizedObjectMapper() {
        ObjectMapper mapper = JacksonUtils.enhancedObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        return mapper;
    }
    ```

2. The `TrafficControlService/src/main/java/dapr/traffic/fines/KafkaConfig.java` file defines `ProducerFactory` and `KafkaTemplate` classes.

    ```java
    @Bean
    public ProducerFactory<String, SpeedingViolation> producerFactory() {
        Map<String, Object> config = new HashMap<>();
        config.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "127.0.0.1:9092");
        config.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        config.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonObjectSerializer.class);
        return new DefaultKafkaProducerFactory(config);
    }

    @Bean
    public KafkaTemplate<String, SpeedingViolation> kafkaTemplate() {
        return new KafkaTemplate<String, SpeedingViolation>(producerFactory());
    }
    ```

3. The `TrafficControlService/src/main/java/dapr/traffic/fines/KafkaFineCollectionClient.java` uses `KafkaTemplate` to publish fine to "test" topic.

    ```java
    @Autowired
    private KafkaTemplate<String, SpeedingViolation> kafkaTemplate;

    @Override
    public void submitForFine(SpeedingViolation speedingViolation) {
        kafkaTemplate.send("test", speedingViolation);

    }
    ```

## Kafka Subscriber

1. The `FineCollectionService/src/main/java/dapr/fines/violation/KafkaConsumerConfig.java` defines a factory class for Kafka listener.

    ```java
    @Bean
    public ConsumerFactory<String, SpeedingViolation> consumerFactory() {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "127.0.0.1:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "test");
        props.put(JsonObjectDeserializer.TRUSTED_PACKAGES, "*");
        return new DefaultKafkaConsumerFactory<>(props, new StringDeserializer(),
                new JsonObjectDeserializer());
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, SpeedingViolation> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, SpeedingViolation>
                factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        return factory;
    }
    ```

2. The `FineCollectionService/src/main/java/dapr/fines/violation/KafkaViolationConsumer.java` file implements kafka listener.

    ```java
    @KafkaListener(topics = "test", groupId = "test", containerFactory = "kafkaListenerContainerFactory")
    public void listen(SpeedingViolation violation) {

        violationProcessor.processSpeedingViolation(violation);
    }
    ```
