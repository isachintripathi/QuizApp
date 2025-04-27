package com.example.mocktest.controller;

import com.example.mocktest.model.*;
import com.example.mocktest.service.DataService;
import com.example.mocktest.service.MCQService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")  // Allow Flutter to access API
public class MockTestController {

    @Autowired
    private DataService dataService;

    @Autowired
    private MCQService  mcqService;

    @GetMapping(value = "/groups", produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<Group>> getGroups() {
        return ResponseEntity.ok(dataService.getGroups());
    }

    @GetMapping(value = "/subgroups/{groupId}", produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<Subgroup>> getSubgroups(@PathVariable String groupId) {
        return ResponseEntity.ok(dataService.getSubgroups(groupId));
    }

    @GetMapping(value = "/exams/{groupId}/{subgroupId}",produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<Exam>> getExams(@PathVariable String groupId, @PathVariable String subgroupId) {
        return ResponseEntity.ok(dataService.getExams(groupId, subgroupId));
    }

    @GetMapping(value = "/subjects/{groupId}/{subgroupId}/{examId}", produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<Subject>> getSubjects(@PathVariable String groupId,
                                                   @PathVariable String subgroupId,
                                                   @PathVariable String examId) {
        return ResponseEntity.ok(dataService.getSubjects(groupId, subgroupId, examId));
    }

    @GetMapping(value = "/chapters/{groupId}/{subgroupId}/{examId}/{subjectId}", produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<Chapter>> getChapters(@PathVariable String groupId,
                                                     @PathVariable String subgroupId,
                                                     @PathVariable String examId,
                                                     @PathVariable String subjectId) {
        return ResponseEntity.ok(dataService.getChapters(groupId, subgroupId, examId, subjectId));
    }

    @GetMapping(value = "/pdfs/{groupId}/{subgroupId}/{examId}/{subject}", produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<String>> getPdfs(@PathVariable String groupId,
                                              @PathVariable String subgroupId,
                                              @PathVariable String examId,
                                              @PathVariable String subject) {
        List<Subject> subjects = dataService.getSubjects(groupId, subgroupId, examId);
        return subjects.stream()
                .filter(s -> s.getName().equalsIgnoreCase(subject))
                .findFirst()
                .map(s -> ResponseEntity.ok(s.getPdfs()))
                .orElse(ResponseEntity.ok(new ArrayList<>()));
    }

    @GetMapping(value = "/docs/{groupId}/{subgroupId}/{examId}/{subject}",produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<String>> getDocs(@PathVariable String groupId,
                                              @PathVariable String subgroupId,
                                              @PathVariable String examId,
                                              @PathVariable String subject) {
        List<Subject> subjects = dataService.getSubjects(groupId, subgroupId, examId);
        return subjects.stream()
                .filter(s -> s.getName().equalsIgnoreCase(subject))
                .findFirst()
                .map(s -> ResponseEntity.ok(s.getDocs()))
                .orElse(ResponseEntity.ok(new ArrayList<>()));
    }

    @GetMapping(value = "/videos/{groupId}/{subgroupId}/{examId}/{subject}",produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<String>> getVideos(@PathVariable String groupId,
                                                @PathVariable String subgroupId,
                                                @PathVariable String examId,
                                                @PathVariable String subject) {
        List<Subject> subjects = dataService.getSubjects(groupId, subgroupId, examId);
        return subjects.stream()
                .filter(s -> s.getName().equalsIgnoreCase(subject))
                .findFirst()
                .map(s -> ResponseEntity.ok(s.getVideos()))
                .orElse(ResponseEntity.ok(new ArrayList<>()));
    }

    @GetMapping(value = "/mcqs/{subjectId}",produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<MCQ>> getMCQs(@PathVariable String subjectId) {
        return ResponseEntity.ok(mcqService.getMCQsBySubject(subjectId));
    }

    @GetMapping(value = "/mcqs",produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<MCQ>> getMCQs(
            @RequestParam(required = false) String topic,
            @RequestParam String subject,
            @RequestParam(defaultValue = "10") int count,
            @RequestParam(required = false) String userId) {
        List<MCQ> result;
        if (topic != null && !topic.isEmpty()) {
            result = mcqService.getMCQsForTopicAndSubject(topic, subject, count, userId);
        } else {
            result = mcqService.getMCQsBySubject(subject);
            // If there are more MCQs than the requested count, limit them
            if (result.size() > count) {
                result = result.subList(0, count);
            }
        }
        return ResponseEntity.ok(result);
    }

    @GetMapping(value = "/mcq-stats",produces = "application/json; charset=UTF-8")
    public Map<String, Object> getMcqStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalMCQs", mcqService.getTotalMCQCount());
        return stats;
    }

    @PostMapping(value = "/reset-mcq-tracking",produces = "application/json; charset=UTF-8")
    public Map<String, String> resetMcqTracking(@RequestParam(required = false) String userId) {
        mcqService.resetRecentlyServedMCQs();
        Map<String, String> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "MCQ tracking reset successfully");
        return response;
    }
}
