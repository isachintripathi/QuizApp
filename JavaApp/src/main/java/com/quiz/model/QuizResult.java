package com.quiz.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class QuizResult {
    private User user;
    private String quizType; // "Subject" or "Set"
    private String quizName; // Subject name or Set name
    private int totalQuestions;
    private int correctAnswers;
    private LocalDateTime submissionTime;
    private List<QuestionResult> questionResults;
    
    public QuizResult(User user, String quizType, String quizName, int totalQuestions, int correctAnswers, 
                     List<QuestionResult> questionResults) {
        this.user = user;
        this.quizType = quizType;
        this.quizName = quizName;
        this.totalQuestions = totalQuestions;
        this.correctAnswers = correctAnswers;
        this.submissionTime = LocalDateTime.now();
        this.questionResults = questionResults;
    }
    
    public User getUser() {
        return user;
    }
    
    public String getQuizType() {
        return quizType;
    }
    
    public String getQuizName() {
        return quizName;
    }
    
    public int getTotalQuestions() {
        return totalQuestions;
    }
    
    public int getCorrectAnswers() {
        return correctAnswers;
    }
    
    public LocalDateTime getSubmissionTime() {
        return submissionTime;
    }
    
    public List<QuestionResult> getQuestionResults() {
        return questionResults;
    }
    
    public String getFormattedSubmissionTime() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
        return submissionTime.format(formatter);
    }
    
    public double getScorePercentage() {
        if (totalQuestions == 0) return 0;
        return (double) correctAnswers / totalQuestions * 100;
    }
    
    public String getResultFileName() {
        String sanitizedName = user.getName().replaceAll("\\s+", "_").toLowerCase();
        return sanitizedName + "_" + getFormattedSubmissionTime() + ".txt";
    }
    
    public static class QuestionResult {
        private String question;
        private String userAnswer;
        private String correctAnswer;
        private boolean isCorrect;
        
        public QuestionResult(String question, String userAnswer, String correctAnswer, boolean isCorrect) {
            this.question = question;
            this.userAnswer = userAnswer;
            this.correctAnswer = correctAnswer;
            this.isCorrect = isCorrect;
        }
        
        public String getQuestion() {
            return question;
        }
        
        public String getUserAnswer() {
            return userAnswer;
        }
        
        public String getCorrectAnswer() {
            return correctAnswer;
        }
        
        public boolean isCorrect() {
            return isCorrect;
        }
    }
} 