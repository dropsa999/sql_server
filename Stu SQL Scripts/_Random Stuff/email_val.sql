CREATE OR REPLACE FUNCTION EMAILVALIDATE_V1(email VARCHAR2) RETURN NUMBER IS
	
  t_valid NUMBER(1);
  t_totallen NUMBER(2);
  t_counter NUMBER(2):=0;
  t_atpos NUMBER(2):= 1;
  i NUMBER(2) := 1;
  t_pointpos NUMBER(2):= 1;
  
  mail_ch VARCHAR2(1);
  
BEGIN
	
  t_totallen := LENGTH(email);
  t_counter := t_totallen;
  i := 1;
  t_valid := 1;

------------------------------------------------------------------------------------- 
    
    IF LENGTH(ltrim(rtrim(email))) = 0 THEN
        t_valid := 0;
    ELSE
---------------------------------------------------------------------------------------    
	--This is to check special characters are present or not in the email ID
	t_counter := t_totallen;

	WHILE t_counter > 0
	   LOOP
		mail_ch := substr(email,i,1);
		i := i+1;
		t_counter := t_counter -1;

		IF mail_ch IN (' ','!','#','$','%','^','&','*','(',')','-','','"',
				     '+','|','{','}','[',']',':','>','<','?','/','\','=') THEN
	    		t_valid := 0;
	    		EXIT;
		END IF;

	  END LOOP;

	---------------------------------------------------------------------------------------    
	--This is to check more than one '@' character present or not

	t_atpos := instr(email,'@',1,2) ;

	IF t_atpos > 1  then
	   t_valid := 0;
	END IF;

	---------------------------------------------------------------------------------------
	--This is to check at minimum and at maximum only one '@' character present

	t_atpos := instr(email,'@',1) ;

	IF t_atpos IN (0,1) THEN
	   t_valid := 0;
	END IF;

	---------------------------------------------------------------------------------------
	--This is to check at least one '.' character present or not

	t_pointpos := instr(email,'.',1) ;

	IF t_pointpos IN (0,1) THEN
	   t_valid := 0;
	END IF;

	---------------------------------------------------------------------------------------

  	END IF;
  
  RETURN t_valid;

END;
