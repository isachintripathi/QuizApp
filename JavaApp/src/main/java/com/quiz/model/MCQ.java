package com.quiz.model;

import java.util.List;

public class MCQ {
    private String id;
    private String question;
    private List<String> options;
    private int correctAnswerIndex;
    private String explanation;
    private String subject;
    private String topic;
    private String difficulty;
    
    public MCQ(String id, String question, List<String> options, int correctAnswerIndex, 
               String explanation, String subject, String topic, String difficulty) {
        this.id = id;
        this.question = question;
        this.options = options;
        this.correctAnswerIndex = correctAnswerIndex;
        this.explanation = explanation;
        this.subject = subject;
        this.topic = topic;
        this.difficulty = difficulty;
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
    
    public String getSubject() {
        return subject;
    }
    
    public void setSubject(String subject) {
        this.subject = subject;
    }
    
    public String getTopic() {
        return topic;
    }
    
    public void setTopic(String topic) {
        this.topic = topic;
    }
    
    public String getDifficulty() {
        return difficulty;
    }
    
    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }
    
    @Override
    public String toString() {
        return "MCQ{" +
                "id='" + id + '\'' +
                ", question='" + question + '\'' +
                ", options=" + options +
                ", correctAnswerIndex=" + correctAnswerIndex +
                ", subject='" + subject + '\'' +
                ", topic='" + topic + '\'' +
                ", difficulty='" + difficulty + '\'' +
                '}';
    }
} 