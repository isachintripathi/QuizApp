package com.example.mocktest.model;

import java.util.List;
import java.util.Objects;
import com.example.mocktest.model.MCQRepository.DifficultyLevel;

public class MCQ {
    private String id;
    private String question;
    private List<String> options;
    private int correctAnswerIndex;
    private String explanation;
    private String topic;
    private String subject;
    private DifficultyLevel difficultyLevel;
    private List<String> tags;
    private long lastServedTimestamp;
    private int timesServed;
    
    public MCQ() {
        this.difficultyLevel = DifficultyLevel.MEDIUM; // Default to medium
    }
    
    public MCQ(String question, List<String> options, int correctAnswerIndex, String explanation) {
        this.question = question;
        this.options = options;
        this.correctAnswerIndex = correctAnswerIndex;
        this.explanation = explanation;
        this.timesServed = 0;
        this.difficultyLevel = DifficultyLevel.MEDIUM; // Default to medium
    }
    
    // Add constructor with id
    public MCQ(String id, String question, List<String> options, int correctAnswerIndex, String explanation) {
        this(question, options, correctAnswerIndex, explanation);
        this.id = id;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }
    
    public String getQuestion() {
        return question;
    }
    
    public void setQuestion(String question) {
        this.question = question;
    }
    
    public List<String> getOptions() {
        return options;
    }
    
    public void setOptions(List<String> options) {
        this.options = options;
    }
    
    public int getCorrectAnswerIndex() {
        return correctAnswerIndex;
    }
    
    public void setCorrectAnswerIndex(int correctAnswerIndex) {
        this.correctAnswerIndex = correctAnswerIndex;
    }
    
    public String getExplanation() {
        return explanation;
    }
    
    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public String getTopic() {
        return topic;
    }

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public DifficultyLevel getDifficultyLevel() {
        return difficultyLevel;
    }

    public void setDifficultyLevel(DifficultyLevel difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }
    
    // For backward compatibility with string-based difficulty levels
    public void setDifficultyLevel(String difficultyLevel) {
        try {
            this.difficultyLevel = DifficultyLevel.valueOf(difficultyLevel.toUpperCase());
        } catch (Exception e) {
            this.difficultyLevel = DifficultyLevel.MEDIUM;
        }
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public long getLastServedTimestamp() {
        return lastServedTimestamp;
    }

    public void setLastServedTimestamp(long lastServedTimestamp) {
        this.lastServedTimestamp = lastServedTimestamp;
    }

    public int getTimesServed() {
        return timesServed;
    }

    public void setTimesServed(int timesServed) {
        this.timesServed = timesServed;
    }
    
    public void incrementTimesServed() {
        this.timesServed++;
        this.lastServedTimestamp = System.currentTimeMillis();
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MCQ mcq = (MCQ) o;
        
        if (id != null && mcq.id != null) {
            return Objects.equals(id, mcq.id);
        }
        
        return Objects.equals(question, mcq.question) &&
               Objects.equals(options, mcq.options) &&
               correctAnswerIndex == mcq.correctAnswerIndex;
    }
    
    @Override
    public int hashCode() {
        if (id != null) {
            return Objects.hash(id);
        }
        return Objects.hash(question, options, correctAnswerIndex);
    }
} 