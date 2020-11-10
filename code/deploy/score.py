# imports at the top

def log_it(service,message,severity):
    lsSeverity = ['PASS', 'WARNING', 'ERROR', 'PAYLOAD', 'RESULT']
    if severity in lsSeverity:
        try:
            json.loads(message)
            message = '{' + '"Service":"{}", "Severity":"{}", "Message":{}'.format(service,severity,message) + '}'
        except:
            message = '{' + '"Service":"{}", "Severity":"{}", "Message":{}'.format(service,severity,message) + '}'
        print(message)
    else:
        message = '{' + '"Service":"{}", "Severity":"{}", "Message":{}'\
            .format(service, 'LOGGING FAIL', '{' + '"Event": "Severity level not recognised, refer to score.py"' + '}') \
                  + '}'
        print(message)



def init():
    # Init is only run once when the docker container is created so don't try to set any variables here that wil be passed as json later
    global model
    # Set the default model CHECK THIS IS RIGHT IT MUST EXIST
    model_path = Model.get_model_path("modelName")
    model = joblib.load(model_path)
    
    
def run(raw_data):
    service = 'ServiceName'
    try:

        messageStart = '{' + '"someId": "{}", "Event": "{}"'.format(applicationids, 'scoring initiated') + '}'
        log_it(service, messageStart,'PASS')
        log_it(service, raw_data, 'PAYLOAD')

       
         # Pull predictors from the model
        predictors = model.feature_names_

         # Fill the predictors I don't have with 0
        for col in predictors:
            if col not in test_data.columns:
                test_data[col] = 0
                messageColMissing = '{' + '"someId": "{}", "Event": "{}", "Item": "{}"'.format(applicationids, 'MissingCol', col) + '}'
                log_it(service, messageColMissing,'WARNING')

        # Loop through each json payload and find a result object

            thisConf =  model.predict_proba(test_data)
            message = '{' + '"someId": "{}", "Confidence": "{}", "Result": "{}"'.format(applicationids[i],thisConf[0], outcome) + '}'
            log_it(service, message,'RESULT')

         # Create a json object to return
      
        messageEnd = '{' + '"someId":"{}", "Event":"{}"'.format(applicationids, 'Scoring Completed') + '}'
        log_it(service,messageEnd,'PASS')

        return y_hat
    except Exception as e:
        try:
            
            messageException = '{' + '"Exception":"{}", "someId":"{}", "RawData":{}'.format(e, application_ids, raw_data) + '}'
            log_it(service, messageException, "ERROR")
            y_hat_safe = []
            for appid in applicationids:
                y_hat_safe.append({"someId":str(appid), "isReject":True})
            return y_hat_safe
        except Exception as e2:
            # this block will only get activated if there is an error with parsing the json at the start of the modelling process
            messageException = '{' + '"Exception":"{}", "someId":"{}", "RawData":{}'.format(e, np.nan, raw_data) + '}'
            log_it(service, messageException, "ERROR")
            y_hat_safe = {"someId":np.nan, "isReject":True}
            return y_hat_safe
