---
title: Spring for Apache Kafka Usage
parent: Assignment 1 - Running Applications with Kafka without using Dapr
has_children: false
nav_order: 1
---

# Spring for Apache Kafka Usage

1. The Spring for Apache Kafka (spring-kafka) project applies core Spring concepts to the development of Kafka-based messaging solutions. It provides a "template" as a high-level abstraction for sending messages. It also provides support for Message-driven POJOs with @KafkaListener annotations and a "listener container".

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

2. The `TrafficControlService/src/main/java/dapr/traffic/fines/KafkaConfig.java`file defines `ProducerFactory` and `KafkaTemplate` classes:

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

3. The `TrafficControlService/src/main/java/dapr/traffic/fines/KafkaFineCollectionClient.java` uses `KafkaTemplate` to publish fine to "test" topic

```java
	@Autowired
	private KafkaTemplate<String, SpeedingViolation> kafkaTemplate;

	@Override
	public void submitForFine(SpeedingViolation speedingViolation) {
		kafkaTemplate.send("test", speedingViolation);

	}
```