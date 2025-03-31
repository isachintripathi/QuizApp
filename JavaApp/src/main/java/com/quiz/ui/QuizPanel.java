package com.quiz.ui;

import com.quiz.model.MCQ;
import com.quiz.model.QuizResult;
import com.quiz.model.User;
import com.quiz.service.QuizService;

import javax.swing.*;
import java.awt.*;
import java.util.List;

public class QuizPanel extends JPanel {
    private JLabel questionLabel;
    private JRadioButton[] optionButtons;
    private ButtonGroup buttonGroup;
    private JButton nextButton;
    private JButton previousButton;
    private JButton submitButton;
    private JLabel questionNumberLabel;
    
    private QuizService quizService;
    private int currentQuestionIndex;
    private JFrame parentFrame;
    
    public QuizPanel(JFrame parentFrame) {
        this.parentFrame = parentFrame;
        this.quizService = new QuizService();
        initComponents();
    }
    
    private void initComponents() {
        setLayout(new BorderLayout());
        
        // Question panel
        JPanel questionPanel = new JPanel(new BorderLayout());
        questionLabel = new JLabel();
        questionLabel.setFont(new Font("SansSerif", Font.BOLD, 14));
        questionPanel.add(questionLabel, BorderLayout.CENTER);
        
        // Options panel
        JPanel optionsPanel = new JPanel(new GridLayout(4, 1, 0, 5));
        buttonGroup = new ButtonGroup();
        optionButtons = new JRadioButton[4];
        
        for (int i = 0; i < optionButtons.length; i++) {
            optionButtons[i] = new JRadioButton();
            final int index = i;
            optionButtons[i].addActionListener(e -> {
                if (quizService.getCurrentUser() != null) {
                    quizService.setAnswer(currentQuestionIndex, index);
                }
            });
            buttonGroup.add(optionButtons[i]);
            optionsPanel.add(optionButtons[i]);
        }
        
        // Navigation panel
        JPanel navigationPanel = new JPanel();
        previousButton = new JButton("Previous");
        nextButton = new JButton("Next");
        submitButton = new JButton("Submit");
        questionNumberLabel = new JLabel();
        
        previousButton.addActionListener(e -> {
            if (currentQuestionIndex > 0) {
                currentQuestionIndex--;
                updateQuestionDisplay();
            }
        });
        
        nextButton.addActionListener(e -> {
            if (currentQuestionIndex < quizService.getQuestions().size() - 1) {
                currentQuestionIndex++;
                updateQuestionDisplay();
            }
        });
        
        submitButton.addActionListener(e -> submitQuiz());
        
        navigationPanel.add(previousButton);
        navigationPanel.add(questionNumberLabel);
        navigationPanel.add(nextButton);
        navigationPanel.add(submitButton);
        
        // Add components to main panel
        add(questionPanel, BorderLayout.NORTH);
        add(optionsPanel, BorderLayout.CENTER);
        add(navigationPanel, BorderLayout.SOUTH);
    }
    
    public void startNewQuiz(List<MCQ> questions, String quizType, String quizName) {
        // Show user details dialog
        User user = UserDetailsDialog.showDialog(parentFrame);
        
        if (user == null) {
            // User cancelled the dialog
            return;
        }
        
        quizService.startNewQuiz(user, questions, quizType, quizName);
        currentQuestionIndex = 0;
        updateQuestionDisplay();
        setVisible(true);
    }
    
    private void updateQuestionDisplay() {
        List<MCQ> questions = quizService.getQuestions();
        if (questions.isEmpty()) {
            return;
        }
        
        MCQ currentQuestion = questions.get(currentQuestionIndex);
        questionLabel.setText("<html><div style='width:400px'>" + currentQuestion.getQuestion() + "</div></html>");
        
        List<String> options = currentQuestion.getOptions();
        for (int i = 0; i < optionButtons.length; i++) {
            if (i < options.size()) {
                optionButtons[i].setText(options.get(i));
                optionButtons[i].setVisible(true);
            } else {
                optionButtons[i].setVisible(false);
            }
        }
        
        // Update question number label
        questionNumberLabel.setText(String.format("Question %d of %d", currentQuestionIndex + 1, questions.size()));
        
        // Set the selected option if the user has already answered this question
        int userAnswer = quizService.getUserAnswer(currentQuestionIndex);
        buttonGroup.clearSelection();
        if (userAnswer >= 0 && userAnswer < optionButtons.length) {
            optionButtons[userAnswer].setSelected(true);
        }
        
        // Update button states
        previousButton.setEnabled(currentQuestionIndex > 0);
        nextButton.setEnabled(currentQuestionIndex < questions.size() - 1);
        submitButton.setEnabled(isQuizComplete());
    }
    
    private boolean isQuizComplete() {
        // Check if all questions have been answered
        for (int i = 0; i < quizService.getQuestions().size(); i++) {
            if (quizService.getUserAnswer(i) == -1) {
                return false;
            }
        }
        return true;
    }
    
    private void submitQuiz() {
        if (!isQuizComplete()) {
            JOptionPane.showMessageDialog(this, 
                    "Please answer all questions before submitting.", 
                    "Incomplete Quiz", 
                    JOptionPane.WARNING_MESSAGE);
            return;
        }
        
        int confirm = JOptionPane.showConfirmDialog(this, 
                "Are you sure you want to submit the quiz?", 
                "Confirm Submission", 
                JOptionPane.YES_NO_OPTION);
        
        if (confirm == JOptionPane.YES_OPTION) {
            try {
                QuizResult result = quizService.finishQuiz();
                showResultScreen(result);
            } catch (Exception e) {
                JOptionPane.showMessageDialog(this, 
                        "Error submitting quiz: " + e.getMessage(), 
                        "Error", 
                        JOptionPane.ERROR_MESSAGE);
                e.printStackTrace();
            }
        }
    }
    
    private void showResultScreen(QuizResult result) {
        // Clear the current panel
        removeAll();
        setLayout(new BorderLayout());
        
        // Create result panel
        JPanel resultPanel = new JPanel(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.gridwidth = GridBagConstraints.REMAINDER;
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;
        
        // Add header
        JLabel headerLabel = new JLabel("Quiz Results", SwingConstants.CENTER);
        headerLabel.setFont(new Font("SansSerif", Font.BOLD, 20));
        gbc.gridx = 0;
        gbc.gridy = 0;
        resultPanel.add(headerLabel, gbc);
        
        // Add user information
        JLabel userLabel = new JLabel("Name: " + result.getUser().getName());
        gbc.gridy = 1;
        resultPanel.add(userLabel, gbc);
        
        // Add quiz information
        JLabel quizTypeLabel = new JLabel("Quiz Type: " + result.getQuizType() + " - " + result.getQuizName());
        gbc.gridy = 2;
        resultPanel.add(quizTypeLabel, gbc);
        
        // Add score
        JLabel scoreLabel = new JLabel(String.format("Score: %d/%d (%.2f%%)", 
                result.getCorrectAnswers(), 
                result.getTotalQuestions(),
                result.getScorePercentage()));
        scoreLabel.setFont(new Font("SansSerif", Font.BOLD, 16));
        gbc.gridy = 3;
        resultPanel.add(scoreLabel, gbc);
        
        // Add completion message
        JLabel completionLabel = new JLabel("Your quiz report has been saved.", SwingConstants.CENTER);
        completionLabel.setFont(new Font("SansSerif", Font.ITALIC, 14));
        gbc.gridy = 4;
        resultPanel.add(completionLabel, gbc);
        
        // Add report location
        JLabel reportLabel = new JLabel("Report saved as: " + result.getResultFileName(), SwingConstants.CENTER);
        gbc.gridy = 5;
        resultPanel.add(reportLabel, gbc);
        
        // Add buttons
        JPanel buttonPanel = new JPanel();
        JButton newQuizButton = new JButton("Start New Quiz");
        JButton closeButton = new JButton("Close");
        
        newQuizButton.addActionListener(e -> {
            // Reset the panel for a new quiz
            removeAll();
            initComponents();
            revalidate();
            repaint();
            setVisible(false);
        });
        
        closeButton.addActionListener(e -> {
            // Close the application or return to main menu
            // This depends on your application flow
            setVisible(false);
        });
        
        buttonPanel.add(newQuizButton);
        buttonPanel.add(closeButton);
        
        gbc.gridy = 6;
        resultPanel.add(buttonPanel, gbc);
        
        // Add result panel to main panel
        add(resultPanel, BorderLayout.CENTER);
        revalidate();
        repaint();
    }
} 