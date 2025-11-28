package kopo.shallwithme.service;

import kopo.shallwithme.dto.MailDTO;

public interface IMailService {

    int doSendMail(MailDTO pDTO);
}
