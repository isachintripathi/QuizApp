package com.quiz.service;

import com.quiz.model.QuizResult;
import com.quiz.model.User;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.format.DateTimeFormatter;

public class ReportGenerator {
    private static final String REPORTS_DIRECTORY = "reports";
    
    public static void generateReport(QuizResult result) {
        try {
            createReportsDirectoryIfNotExists();
            String filePath = REPORTS_DIRECTORY + File.separator + result.getResultFileName();
            
            try (FileWriter writer = new FileWriter(filePath)) {
                writeReportHeader(writer, result);
                writeUserDetails(writer, result.getUser());
                writeQuizDetails(writer, result);
                writeQuestionResults(writer, result);
                writeSummary(writer, result);
            }
            
            System.out.println("Report generated successfully: " + filePath);
        } catch (IOException e) {
            System.err.println("Error generating report: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static void createReportsDirectoryIfNotExists() throws IOException {
        Path reportsDirPath = Paths.get(REPORTS_DIRECTORY);
        if (!Files.exists(reportsDirPath)) {
            Files.createDirectories(reportsDirPath);
        }
    }
    
    private static void writeReportHeader(FileWriter writer, QuizResult result) throws IOException {
        writer.write("==========================================================\n");
        writer.write("                       QUIZ REPORT                        \n");
        writer.write("==========================================================\n\n");
        
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss");
        writer.write("Date and Time: " + result.getSubmissionTime().format(formatter) + "\n\n");
    }
    
    private static void writeUserDetails(FileWriter writer, User user) throws IOException {
        writer.write("----------------------------------------------------------\n");
        writer.write("USER DETAILS\n");
        writer.write("----------------------------------------------------------\n");
        writer.write("Name: " + user.getName() + "\n");
        writer.write("Date of Birth: " + user.getFormattedDateOfBirth() + "\n\n");
    }
    
    private static void writeQuizDetails(FileWriter writer, QuizResult result) throws IOException {
        writer.write("----------------------------------------------------------\n");
        writer.write("QUIZ DETAILS\n");
        writer.write("----------------------------------------------------------\n");
        writer.write("Quiz Type: " + result.getQuizType() + "\n");
        writer.write("Quiz Name: " + result.getQuizName() + "\n");
        writer.write("Total Questions: " + result.getTotalQuestions() + "\n");
        writer.write("Correct Answers: " + result.getCorrectAnswers() + "\n");
        writer.write("Score: " + String.format("%.2f", result.getScorePercentage()) + "%\n\n");
    }
    
    private static void writeQuestionResults(FileWriter writer, QuizResult result) throws IOException {
        writer.write("----------------------------------------------------------\n");
        writer.write("QUESTION DETAILS\n");
        writer.write("----------------------------------------------------------\n");
        
        int questionNumber = 1;
        for (QuizResult.QuestionResult questionResult : result.getQuestionResults()) {
            writer.write("Question " + questionNumber + ": " + questionResult.getQuestion() + "\n");
            writer.write("Your Answer: " + questionResult.getUserAnswer() + "\n");
            writer.write("Correct Answer: " + questionResult.getCorrectAnswer() + "\n");
            writer.write("Result: " + (questionResult.isCorrect() ? "CORRECT" : "INCORRECT") + "\n\n");
            questionNumber++;
        }
    }
    
    private static void writeSummary(FileWriter writer, QuizResult result) throws IOException {
        writer.write("==========================================================\n");
        writer.write("SUMMARY\n");
        writer.write("==========================================================\n");
        writer.write("Total Questions: " + result.getTotalQuestions() + "\n");
        writer.write("Correct Answers: " + result.getCorrectAnswers() + "\n");
        writer.write("Incorrect Answers: " + (result.getTotalQuestions() - result.getCorrectAnswers()) + "\n");
        writer.write("Final Score: " + String.format("%.2f", result.getScorePercentage()) + "%\n");
        
        // Add performance evaluation
        writer.write("\nPerformance Evaluation: ");
        double percentage = result.getScorePercentage();
        if (percentage >= 90) {
            writer.write("Excellent! Keep up the good work.\n");
        } else if (percentage >= 75) {
            writer.write("Good! You're on the right track.\n");
        } else if (percentage >= 60) {
            writer.write("Satisfactory. With more practice, you can improve.\n");
        } else if (percentage >= 40) {
            writer.write("Needs improvement. Focus on your weak areas.\n");
        } else {
            writer.write("Requires significant improvement. Consider revisiting the material and try again.\n");
        }
    }
} 