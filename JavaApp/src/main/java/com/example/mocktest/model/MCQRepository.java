package com.example.mocktest.model;

import org.springframework.stereotype.Repository;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.stream.Collectors;

/**
 * Central repository for managing MCQs with advanced filtering and selection
 */
@Repository
public class MCQRepository {
    
    // Main storage of all MCQs
    private final List<MCQ> allMCQs = new ArrayList<>();
    
    // MCQs organized by topic and subject for faster access
    private final Map<String, Map<String, List<MCQ>>> mcqsByTopicAndSubject = new HashMap<>();
    
    // MCQs organized by difficulty level
    private final Map<DifficultyLevel, List<MCQ>> mcqsByDifficulty = new HashMap<>();
    
    // Tracks which MCQs have been recently served to avoid repetition
    private final Map<String, List<Integer>> recentlyServedMCQIds = new HashMap<>();
    
    private final Random random = new Random();
    
    public enum DifficultyLevel {
        EASY, MEDIUM, HARD
    }
    
    /**
     * Add a new MCQ to the repository with metadata
     */
    public void addMCQ(MCQ mcq, String topic, String subject, DifficultyLevel difficulty) {
        // Add unique ID if not present
        if (mcq.getId() == null || mcq.getId().isEmpty()) {
            mcq.setId(generateUniqueId());
        }
        
        // Set metadata
        mcq.setTopic(topic);
        mcq.setSubject(subject);
        mcq.setDifficultyLevel(difficulty);
        
        // Add to main list
        allMCQs.add(mcq);
        
        // Add to topic-subject map
        mcqsByTopicAndSubject
            .computeIfAbsent(topic, k -> new HashMap<>())
            .computeIfAbsent(subject, k -> new ArrayList<>())
            .add(mcq);
        
        // Add to difficulty map
        mcqsByDifficulty
            .computeIfAbsent(difficulty, k -> new ArrayList<>())
            .add(mcq);
    }
    
    /**
     * Get MCQs for a specific topic and subject with configurable uniqueness
     */
    public List<MCQ> getMCQs(String topic, String subject, int count, boolean ensureUnique) {
        String key = topic + "-" + subject;
        List<MCQ> availableMCQs = getMCQsForTopicAndSubject(topic, subject);
        
        if (availableMCQs.isEmpty()) {
            return new ArrayList<>();
        }
        
        // If we need to ensure uniqueness (no recent repeats)
        if (ensureUnique && recentlyServedMCQIds.containsKey(key)) {
            List<Integer> recentIds = recentlyServedMCQIds.get(key);
            availableMCQs = availableMCQs.stream()
                .filter(mcq -> !recentIds.contains(mcq.hashCode()))
                .collect(Collectors.toList());
        }
        
        // If after filtering, we don't have enough, just use all available
        if (availableMCQs.size() < count) {
            availableMCQs = getMCQsForTopicAndSubject(topic, subject);
        }
        
        // Shuffle the list for randomness
        java.util.Collections.shuffle(availableMCQs, random);
        
        // Take required number, or all if less are available
        List<MCQ> selectedMCQs = availableMCQs.size() <= count ? 
            new ArrayList<>(availableMCQs) : 
            availableMCQs.subList(0, count);
        
        // Record these as recently served
        if (ensureUnique) {
            List<Integer> mcqIds = selectedMCQs.stream()
                .map(Object::hashCode)
                .collect(Collectors.toList());
                
            recentlyServedMCQIds.put(key, mcqIds);
        }
        
        return selectedMCQs;
    }
    
    /**
     * Get MCQs for a test set with specific difficulty distribution
     */
    public List<MCQ> getMCQsForTest(String topic, int easyPercent, int mediumPercent, int hardPercent, int totalCount) {
        if (easyPercent + mediumPercent + hardPercent != 100) {
            throw new IllegalArgumentException("Difficulty percentages must sum to 100");
        }
        
        int easyCount = (easyPercent * totalCount) / 100;
        int mediumCount = (mediumPercent * totalCount) / 100;
        int hardCount = totalCount - easyCount - mediumCount;
        
        List<MCQ> result = new ArrayList<>();
        
        // Get MCQs for each difficulty level from the topic
        result.addAll(getTopicMCQsByDifficulty(topic, DifficultyLevel.EASY, easyCount));
        result.addAll(getTopicMCQsByDifficulty(topic, DifficultyLevel.MEDIUM, mediumCount));
        result.addAll(getTopicMCQsByDifficulty(topic, DifficultyLevel.HARD, hardCount));
        
        // If we couldn't get enough questions, fill with any available
        if (result.size() < totalCount) {
            List<MCQ> allTopicMCQs = getTopicMCQs(topic);
            allTopicMCQs.removeAll(result); // Remove already added
            
            if (!allTopicMCQs.isEmpty()) {
                java.util.Collections.shuffle(allTopicMCQs, random);
                int remaining = Math.min(totalCount - result.size(), allTopicMCQs.size());
                result.addAll(allTopicMCQs.subList(0, remaining));
            }
        }
        
        // Shuffle to mix difficulty levels
        java.util.Collections.shuffle(result, random);
        
        return result;
    }
    
    /**
     * Helper method to get MCQs by topic and difficulty level
     */
    private List<MCQ> getTopicMCQsByDifficulty(String topic, DifficultyLevel level, int count) {
        List<MCQ> topicMCQs = getTopicMCQs(topic);
        
        List<MCQ> filteredByDifficulty = topicMCQs.stream()
            .filter(mcq -> mcq.getDifficultyLevel().equals(level.toString()))
            .collect(Collectors.toList());
            
        java.util.Collections.shuffle(filteredByDifficulty, random);
        
        return filteredByDifficulty.size() <= count ? 
            new ArrayList<>(filteredByDifficulty) : 
            filteredByDifficulty.subList(0, count);
    }
    
    /**
     * Get all MCQs for a topic across all subjects
     */
    public List<MCQ> getTopicMCQs(String topic) {
        if (!mcqsByTopicAndSubject.containsKey(topic)) {
            return new ArrayList<>();
        }
        
        List<MCQ> result = new ArrayList<>();
        
        for (List<MCQ> subjectMCQs : mcqsByTopicAndSubject.get(topic).values()) {
            result.addAll(subjectMCQs);
        }
        
        return result;
    }
    
    /**
     * Helper to get MCQs for a specific topic and subject
     */
    public List<MCQ> getMCQsForTopicAndSubject(String topic, String subject) {
        if (!mcqsByTopicAndSubject.containsKey(topic) || 
            !mcqsByTopicAndSubject.get(topic).containsKey(subject)) {
            return new ArrayList<>();
        }
        
        return mcqsByTopicAndSubject.get(topic).get(subject);
    }
    
    /**
     * Get MCQs for a specific topic
     */
    public List<MCQ> getMCQsForTopic(String topic) {
        if (topic == null || topic.isEmpty()) {
            // Return all MCQs if no topic specified
            return new ArrayList<>(allMCQs);
        }
        
        return getTopicMCQs(topic);
    }
    
    /**
     * Generate a unique ID for new MCQs
     */
    private String generateUniqueId() {
        return "mcq_" + System.currentTimeMillis() + "_" + random.nextInt(10000);
    }
    
    /**
     * Clear recently served MCQs to reset uniqueness tracking
     */
    public void resetRecentlyServedMCQs() {
        recentlyServedMCQIds.clear();
    }
    
    /**
     * Get the total count of MCQs in the repository
     */
    public int getTotalMCQCount() {
        return allMCQs.size();
    }
} 