package kopo.shallwithme.service;

import kopo.shallwithme.dto.MailDTO;

public interface IMailService {

    //메일 발송
    int doSendMail(MailDTO pDTO);
}
