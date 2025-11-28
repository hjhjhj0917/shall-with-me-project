package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class ScheduleDTO {

    private int scheduleId;
    private String title;
    private String scheduleDt;
    private String location;
    private String memo;
    private String creatorId;
    private String participantId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String status;
    private String roomId;

}
