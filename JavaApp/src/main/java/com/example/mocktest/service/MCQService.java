package com.example.mocktest.service;

import com.example.mocktest.model.MCQ;
import com.example.mocktest.model.MCQRepository;
import com.example.mocktest.model.MCQRepository.DifficultyLevel;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Service for managing MCQs
 */
@Service
public class MCQService {
    private static final Logger logger = LoggerFactory.getLogger(MCQService.class);
    
    private final MCQRepository mcqRepository;
    
    // Track recently served MCQs for each user to avoid repetition
    private final Map<String, List<String>> userMCQTracker = new HashMap<>();
    
    private final ObjectMapper objectMapper;
    private List<MCQ> mcqs;
    
    @Autowired
    public MCQService(MCQRepository mcqRepository, ObjectMapper objectMapper) {
        this.mcqRepository = mcqRepository;
        this.objectMapper = objectMapper;
        this.mcqs = new ArrayList<>();
        loadMCQsFromFiles();
    }
    
    @PostConstruct
    public void init() {
        loadSampleMCQs(); // Load some initial MCQs
        loadMCQsFromFiles(); // Load MCQs from JSON files
    }

    private void loadMCQsFromFiles() {
        try {
            Path mcqsDir = Paths.get("src/main/resources/mcqs");
            if (Files.exists(mcqsDir)) {
                Files.walk(mcqsDir)
                    .filter(path -> path.toString().endsWith(".json"))
                    .forEach(this::loadMCQsFromFile);
            }
        } catch (IOException e) {
            logger.error("Error loading MCQs from files", e);
        }
    }

    private void loadMCQsFromFile(Path file) {
        try {
            // First try to read as a list of MCQs (old format)
            try {
                List<MCQ> fileMcqs = objectMapper.readValue(file.toFile(),
                    objectMapper.getTypeFactory().constructCollectionType(List.class, MCQ.class));
                mcqs.addAll(fileMcqs);
                logger.info("Loaded {} MCQs from {} (old format)", fileMcqs.size(), file);
            } catch (Exception e) {
                // If that fails, try the new format with subject and questions
                var rootNode = objectMapper.readTree(file.toFile());
                if (rootNode.has("subject") && rootNode.has("questions")) {
                    String subject = rootNode.get("subject").asText();
                    List<MCQ> fileMcqs = objectMapper.convertValue(
                        rootNode.get("questions"),
                        objectMapper.getTypeFactory().constructCollectionType(List.class, MCQ.class)
                    );
                    
                    // Set the subject for each MCQ
                    fileMcqs.forEach(mcq -> {
                        mcq.setSubject(subject);
                        // Extract exam name from file name (format: examname_subjectname.json)
                        String fileName = file.getFileName().toString();
                        int underscoreIndex = fileName.indexOf('_');
                        if (underscoreIndex > 0) {
                            String examName = fileName.substring(0, underscoreIndex);
                            mcq.setTopic(examName);
                        } else {
                            // If no underscore found, use the filename without extension as the topic
                            int dotIndex = fileName.lastIndexOf('.');
                            String examName = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
                            mcq.setTopic(examName);
                        }
                    });
                    
                    mcqs.addAll(fileMcqs);
                    logger.info("Loaded {} MCQs from {} (new format)", fileMcqs.size(), file);
                } else {
                    logger.error("Invalid MCQ file format: {}", file);
                }
            }
        } catch (IOException e) {
            logger.error("Error loading MCQs from file: {}", file, e);
        }
    }

    private void loadSampleMCQs() {
        // For each topic, generate MCQs for each subject
        generateSampleMCQsForTopicAndSubject("mathematics", "algebra", 30);
        generateSampleMCQsForTopicAndSubject("mathematics", "geometry", 30);
        generateSampleMCQsForTopicAndSubject("mathematics", "calculus", 30);
        
        generateSampleMCQsForTopicAndSubject("physics", "mechanics", 30);
        generateSampleMCQsForTopicAndSubject("physics", "electricity", 30);
        generateSampleMCQsForTopicAndSubject("physics", "optics", 30);
        
        generateSampleMCQsForTopicAndSubject("chemistry", "organic", 30);
        generateSampleMCQsForTopicAndSubject("chemistry", "inorganic", 30);
        generateSampleMCQsForTopicAndSubject("chemistry", "physical", 30);
        
        generateSampleMCQsForTopicAndSubject("biology", "botany", 30);
        generateSampleMCQsForTopicAndSubject("biology", "zoology", 30);
        generateSampleMCQsForTopicAndSubject("biology", "human_anatomy", 30);
        
        generateSampleMCQsForTopicAndSubject("history", "indian_history", 30);
        generateSampleMCQsForTopicAndSubject("history", "world_history", 30);
        generateSampleMCQsForTopicAndSubject("history", "modern_history", 30);
    }
    
    private void generateSampleMCQsForTopicAndSubject(String topic, String subject, int count) {
        logger.info("Generating {} sample MCQs for topic: {}, subject: {}", count, topic, subject);
        
        // Calculate difficulty distribution: 40% easy, 40% medium, 20% hard
        int easyCount = (int) (count * 0.4);
        int mediumCount = (int) (count * 0.4);
        int hardCount = count - easyCount - mediumCount;
        
        // Generate MCQs with different difficulty levels
        for (int i = 0; i < easyCount; i++) {
            MCQ mcq = createSampleMCQ(topic, subject, DifficultyLevel.EASY, i);
            mcqRepository.addMCQ(mcq, topic, subject, DifficultyLevel.EASY);
        }
        
        for (int i = 0; i < mediumCount; i++) {
            MCQ mcq = createSampleMCQ(topic, subject, DifficultyLevel.MEDIUM, i + easyCount);
            mcqRepository.addMCQ(mcq, topic, subject, DifficultyLevel.MEDIUM);
        }
        
        for (int i = 0; i < hardCount; i++) {
            MCQ mcq = createSampleMCQ(topic, subject, DifficultyLevel.HARD, i + easyCount + mediumCount);
            mcqRepository.addMCQ(mcq, topic, subject, DifficultyLevel.HARD);
        }
    }
    
    private MCQ createSampleMCQ(String topic, String subject, DifficultyLevel difficulty, int index) {
        String id = topic + "-" + subject + "-" + difficulty.name().toLowerCase() + "-" + index;
        String question = "Sample " + difficulty.name().toLowerCase() + " question " + index + " for " + topic + " - " + subject;
        List<String> options = Arrays.asList(
                "Option A", 
                "Option B", 
                "Option C", 
                "Option D"
        );
        int correctAnswerIndex = new Random().nextInt(4);
        String explanation = "This is an explanation for the correct answer: " + options.get(correctAnswerIndex);
        
        MCQ mcq = new MCQ(id, question, options, correctAnswerIndex, explanation);
        mcq.setTopic(topic);
        mcq.setSubject(subject);
        mcq.setDifficultyLevel(difficulty);
        mcq.setTags(Arrays.asList(topic, subject, difficulty.name().toLowerCase()));
        
        return mcq;
    }
    
    public List<MCQ> getMCQsForTopicAndSubject(String topic, String subject, int count, String userId) {
        List<MCQ> mcqs = mcqRepository.getMCQsForTopicAndSubject(topic, subject);
        
        // Filter out recently served MCQs for this user
        if (userId != null && userMCQTracker.containsKey(userId)) {
            List<String> recentMCQIds = userMCQTracker.get(userId);
            mcqs = mcqs.stream()
                    .filter(mcq -> !recentMCQIds.contains(mcq.getId()))
                    .collect(Collectors.toList());
        }
        
        // If we still have more MCQs than needed, shuffle and take a subset
        if (mcqs.size() > count) {
            Collections.shuffle(mcqs);
            mcqs = mcqs.subList(0, count);
        }
        
        // Track these MCQs as served to this user
        if (userId != null) {
            trackMCQsForUser(userId, mcqs);
        }
        
        return mcqs;
    }
    
    public List<MCQ> getMCQsForTopic(String topic, int count, String userId) {
        List<MCQ> mcqs = mcqRepository.getMCQsForTopic(topic);
        
        // Filter out recently served MCQs for this user
        if (userId != null && userMCQTracker.containsKey(userId)) {
            List<String> recentMCQIds = userMCQTracker.get(userId);
            mcqs = mcqs.stream()
                    .filter(mcq -> !recentMCQIds.contains(mcq.getId()))
                    .collect(Collectors.toList());
        }
        
        // If we still have more MCQs than needed, shuffle and take a subset
        if (mcqs.size() > count) {
            Collections.shuffle(mcqs);
            mcqs = mcqs.subList(0, count);
        }
        
        // Track these MCQs as served to this user
        if (userId != null) {
            trackMCQsForUser(userId, mcqs);
        }
        
        return mcqs;
    }
    
    public List<MCQ> getCustomTest(String topic, int count, int easyPercentage, int mediumPercentage, int hardPercentage, String userId) {
        // Calculate number of questions for each difficulty level
        int easyCount = (int) Math.round(count * easyPercentage / 100.0);
        int mediumCount = (int) Math.round(count * mediumPercentage / 100.0);
        int hardCount = count - easyCount - mediumCount;
        
        // Get all MCQs for the topic
        List<MCQ> allMcqs = mcqRepository.getMCQsForTopic(topic);
        
        // Filter out recently served MCQs for this user
        if (userId != null && userMCQTracker.containsKey(userId)) {
            List<String> recentMCQIds = userMCQTracker.get(userId);
            allMcqs = allMcqs.stream()
                    .filter(mcq -> !recentMCQIds.contains(mcq.getId()))
                    .collect(Collectors.toList());
        }
        
        // Split MCQs by difficulty level
        Map<DifficultyLevel, List<MCQ>> mcqsByDifficulty = allMcqs.stream()
                .collect(Collectors.groupingBy(MCQ::getDifficultyLevel));
        
        // Get MCQs for each difficulty level
        List<MCQ> easyMcqs = getRandomSubset(mcqsByDifficulty.getOrDefault(DifficultyLevel.EASY, new ArrayList<>()), easyCount);
        List<MCQ> mediumMcqs = getRandomSubset(mcqsByDifficulty.getOrDefault(DifficultyLevel.MEDIUM, new ArrayList<>()), mediumCount);
        List<MCQ> hardMcqs = getRandomSubset(mcqsByDifficulty.getOrDefault(DifficultyLevel.HARD, new ArrayList<>()), hardCount);
        
        // Combine all MCQs
        List<MCQ> result = new ArrayList<>();
        result.addAll(easyMcqs);
        result.addAll(mediumMcqs);
        result.addAll(hardMcqs);
        
        // Shuffle the result
        Collections.shuffle(result);
        
        // Track these MCQs as served to this user
        if (userId != null) {
            trackMCQsForUser(userId, result);
        }
        
        return result;
    }
    
    private List<MCQ> getRandomSubset(List<MCQ> mcqs, int count) {
        if (mcqs.size() <= count) {
            return new ArrayList<>(mcqs);
        }
        
        Collections.shuffle(mcqs);
        return mcqs.subList(0, count);
    }
    
    private void trackMCQsForUser(String userId, List<MCQ> mcqs) {
        userMCQTracker.computeIfAbsent(userId, k -> new ArrayList<>());
        List<String> userMCQs = userMCQTracker.get(userId);
        
        for (MCQ mcq : mcqs) {
            // Update the MCQ's served stats
            mcq.incrementTimesServed();
            
            // Add to user tracker
            if (!userMCQs.contains(mcq.getId())) {
                userMCQs.add(mcq.getId());
            }
            
            // Keep only the 500 most recent MCQs per user
            if (userMCQs.size() > 500) {
                userMCQs.remove(0);
            }
        }
    }
    
    public void resetUserTracking(String userId) {
        if (userId != null) {
            userMCQTracker.remove(userId);
        }
    }
    
    public int getTotalMCQCount() {
        return mcqs.size() + mcqRepository.getTotalMCQCount();
    }
    
    public Map<String, Integer> getMCQCountByDifficulty() {
        Map<String, Integer> result = new HashMap<>();
        
        for (DifficultyLevel level : DifficultyLevel.values()) {
            List<MCQ> mcqsWithDifficulty = mcqRepository.getTopicMCQs("").stream()
                .filter(mcq -> mcq.getDifficultyLevel() == level)
                .collect(Collectors.toList());
            
            result.put(level.name(), mcqsWithDifficulty.size());
        }
        
        return result;
    }
    
    public Map<String, Map<String, Integer>> getMCQCountByTopicAndSubject() {
        Map<String, Map<String, Integer>> result = new HashMap<>();
        
        // Group MCQs by topic and subject
        Map<String, Map<String, List<MCQ>>> groupedMCQs = mcqRepository.getTopicMCQs("").stream()
            .collect(Collectors.groupingBy(
                MCQ::getTopic,
                Collectors.groupingBy(MCQ::getSubject)
            ));
        
        // Count MCQs for each topic and subject
        for (Map.Entry<String, Map<String, List<MCQ>>> topicEntry : groupedMCQs.entrySet()) {
            Map<String, Integer> subjectCounts = new HashMap<>();
            
            for (Map.Entry<String, List<MCQ>> subjectEntry : topicEntry.getValue().entrySet()) {
                subjectCounts.put(subjectEntry.getKey(), subjectEntry.getValue().size());
            }
            
            result.put(topicEntry.getKey(), subjectCounts);
        }
        
        return result;
    }

    public List<MCQ> getMCQs(String topic, String subject, int count) {
        return getMCQsForTopicAndSubject(topic, subject, count, null);
    }

    public List<MCQ> getMCQsForTest(String topic, int count) {
        return getMCQsForTopic(topic, count, null);
    }

    public void trackUserMCQs(String userId, List<MCQ> mcqs) {
        if (userId != null && mcqs != null && !mcqs.isEmpty()) {
            trackMCQsForUser(userId, mcqs);
        }
    }

    public List<MCQ> getCustomTestMCQs(String topic, int count, int easyPercentage, int mediumPercentage, int hardPercentage) {
        return getCustomTest(topic, count, easyPercentage, mediumPercentage, hardPercentage, null);
    }

    public void resetRecentlyServedMCQs() {
        mcqRepository.resetRecentlyServedMCQs();
        userMCQTracker.clear();
    }

    public List<MCQ> getMCQsBySubject(String subject) {
        logger.debug("Getting MCQs for subject: {}", subject);
        List<MCQ> result = mcqs.stream()
                .filter(mcq -> mcq.getSubject() != null && mcq.getSubject().equalsIgnoreCase(subject))
                .collect(Collectors.toList());
        logger.debug("Found {} MCQs for subject: {}", result.size(), subject);
        return result;
    }

    public List<MCQ> getMCQsByTopic(String topic) {
        return mcqs.stream()
                .filter(mcq -> mcq.getTopic().equalsIgnoreCase(topic))
                .collect(Collectors.toList());
    }
} 