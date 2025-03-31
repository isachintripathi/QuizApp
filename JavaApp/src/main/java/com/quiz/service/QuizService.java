package com.quiz.service;

import com.quiz.model.MCQ;
import com.quiz.model.QuizResult;
import com.quiz.model.User;

import java.util.ArrayList;
import java.util.List;

public class QuizService {
    private User currentUser;
    private List<MCQ> questions;
    private List<Integer> userAnswers;
    private String quizType; // "Subject" or "Set"
    private String quizName; // Subject name or Set name
    
    public QuizService() {
        this.questions = new ArrayList<>();
        this.userAnswers = new ArrayList<>();
    }
    
    public void startNewQuiz(User user, List<MCQ> questions, String quizType, String quizName) {
        this.currentUser = user;
        this.questions = questions;
        this.userAnswers = new ArrayList<>(questions.size());
        // Initialize with -1 (no answer)
        for (int i = 0; i < questions.size(); i++) {
            userAnswers.add(-1);
        }
        this.quizType = quizType;
        this.quizName = quizName;
    }
    
    public void setAnswer(int questionIndex, int answerIndex) {
        if (questionIndex >= 0 && questionIndex < userAnswers.size()) {
            userAnswers.set(questionIndex, answerIndex);
        }
    }
    
    public QuizResult finishQuiz() {
        if (currentUser == null || questions.isEmpty()) {
            throw new IllegalStateException("No active quiz in progress");
        }
        
        int correctCount = 0;
        List<QuizResult.QuestionResult> results = new ArrayList<>();
        
        for (int i = 0; i < questions.size(); i++) {
            MCQ question = questions.get(i);
            int userAnswerIndex = userAnswers.get(i);
            boolean isCorrect = userAnswerIndex == question.getCorrectAnswerIndex();
            
            if (isCorrect) {
                correctCount++;
            }
            
            String userAnswer = userAnswerIndex >= 0 && userAnswerIndex < question.getOptions().size() ? 
                                question.getOptions().get(userAnswerIndex) : "No answer";
            String correctAnswer = question.getOptions().get(question.getCorrectAnswerIndex());
            
            results.add(new QuizResult.QuestionResult(
                    question.getQuestion(),
                    userAnswer,
                    correctAnswer,
                    isCorrect
            ));
        }
        
        QuizResult quizResult = new QuizResult(
                currentUser, 
                quizType,
                quizName,
                questions.size(),
                correctCount,
                results
        );
        
        // Generate and save report
        ReportGenerator.generateReport(quizResult);
        
        // Reset the current quiz
        resetQuiz();
        
        return quizResult;
    }
    
    private void resetQuiz() {
        this.currentUser = null;
        this.questions.clear();
        this.userAnswers.clear();
        this.quizType = null;
        this.quizName = null;
    }
    
    public User getCurrentUser() {
        return currentUser;
    }
    
    public List<MCQ> getQuestions() {
        return questions;
    }
    
    public int getUserAnswer(int questionIndex) {
        if (questionIndex >= 0 && questionIndex < userAnswers.size()) {
            return userAnswers.get(questionIndex);
        }
        return -1;
    }
    
    public String getQuizType() {
        return quizType;
    }
    
    public String getQuizName() {
        return quizName;
    }
} 