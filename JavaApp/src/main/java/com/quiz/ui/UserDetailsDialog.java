package com.quiz.ui;

import com.quiz.model.User;

import javax.swing.*;
import java.awt.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class UserDetailsDialog extends JDialog {
    private JTextField nameField;
    private JTextField dobField;
    private User user;
    private boolean confirmed;

    public UserDetailsDialog(JFrame parent) {
        super(parent, "Enter Your Details", true);
        initComponents();
        setLocationRelativeTo(parent);
    }

    private void initComponents() {
        JPanel panel = new JPanel(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        // Name label and field
        gbc.gridx = 0;
        gbc.gridy = 0;
        panel.add(new JLabel("Name:"), gbc);

        gbc.gridx = 1;
        gbc.weightx = 1.0;
        nameField = new JTextField(20);
        panel.add(nameField, gbc);

        // Date of Birth label and field
        gbc.gridx = 0;
        gbc.gridy = 1;
        gbc.weightx = 0.0;
        panel.add(new JLabel("Date of Birth (DD-MM-YYYY):"), gbc);

        gbc.gridx = 1;
        gbc.weightx = 1.0;
        dobField = new JTextField(10);
        panel.add(dobField, gbc);

        // Add helpful instructions
        gbc.gridx = 0;
        gbc.gridy = 2;
        gbc.gridwidth = 2;
        JLabel instructionsLabel = new JLabel("<html>Please enter your full name and date of birth.<br>" +
                "This information will be used to generate your quiz report.</html>");
        instructionsLabel.setFont(new Font("SansSerif", Font.ITALIC, 12));
        panel.add(instructionsLabel, gbc);

        // Buttons panel
        gbc.gridx = 0;
        gbc.gridy = 3;
        gbc.gridwidth = 2;
        gbc.anchor = GridBagConstraints.CENTER;

        JPanel buttonPanel = new JPanel();
        JButton submitButton = new JButton("Submit");
        JButton cancelButton = new JButton("Cancel");
        
        submitButton.addActionListener(e -> {
            if (validateInput()) {
                confirmed = true;
                dispose();
            }
        });
        
        cancelButton.addActionListener(e -> {
            confirmed = false;
            dispose();
        });

        buttonPanel.add(submitButton);
        buttonPanel.add(cancelButton);
        panel.add(buttonPanel, gbc);

        // Set dialog properties
        getContentPane().add(panel);
        pack();
        setResizable(false);
        setDefaultCloseOperation(DISPOSE_ON_CLOSE);
    }

    private boolean validateInput() {
        // Validate name
        String name = nameField.getText().trim();
        if (name.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Please enter your name.", "Input Error", JOptionPane.ERROR_MESSAGE);
            nameField.requestFocus();
            return false;
        }

        // Validate date of birth
        String dobString = dobField.getText().trim();
        if (dobString.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Please enter your date of birth.", "Input Error", JOptionPane.ERROR_MESSAGE);
            dobField.requestFocus();
            return false;
        }

        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");
            LocalDate dob = LocalDate.parse(dobString, formatter);
            
            // Check if date is future date
            if (dob.isAfter(LocalDate.now())) {
                JOptionPane.showMessageDialog(this, "Date of birth cannot be in the future.", 
                        "Input Error", JOptionPane.ERROR_MESSAGE);
                dobField.requestFocus();
                return false;
            }
            
            // Create user object
            user = new User(name, dob);
            return true;
        } catch (DateTimeParseException e) {
            JOptionPane.showMessageDialog(this, "Invalid date format. Please use DD-MM-YYYY format.",
                    "Input Error", JOptionPane.ERROR_MESSAGE);
            dobField.requestFocus();
            return false;
        }
    }

    public User getUser() {
        return user;
    }

    public boolean isConfirmed() {
        return confirmed;
    }

    public static User showDialog(JFrame parent) {
        UserDetailsDialog dialog = new UserDetailsDialog(parent);
        dialog.setVisible(true);
        
        if (dialog.isConfirmed()) {
            return dialog.getUser();
        }
        return null;
    }
} 