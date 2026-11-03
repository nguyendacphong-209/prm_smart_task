package com.example.prm_smart_task.feature.activity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.Instant;
import java.util.UUID;
@Entity @Table(name="task_activities") @Getter @Setter
public class TaskActivity {
 @Id @GeneratedValue(strategy=GenerationType.UUID) private UUID id;
 @Column(nullable=false) private UUID taskId;
 @Column(nullable=false) private UUID actorId;
 @Column(nullable=false) private String actorName;
 @Column(nullable=false) private String field;
 @Column(columnDefinition="TEXT") private String oldValue;
 @Column(columnDefinition="TEXT") private String newValue;
 @Column(nullable=false) private Instant createdAt;
}
