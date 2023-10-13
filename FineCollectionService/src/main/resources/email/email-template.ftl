<html>
<head>
  <title>Fine Collection Agency</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    .logo {
      width: 50%;
      margin: 0 auto;
      padding: 0;
    }
    .logo-label {
      color: #FFFFFF;
      background-color: rgb(21, 180, 74);
      vertical-align: middle;
      padding: 10px;
      margin-top: 20px;
      height: 20px;
    }
    .text {
        margin: 0 auto;
        width: 46%;
        border-radius: 10px;
        padding: 20px;
    }
    p {
        font-size: 14px;
    }
    .end-bar {
      background-color: rgb(10, 107, 43);
      width: 50%;
      height: 5px;
      margin: 0 auto;
      margin-top: 30px;
      margin-bottom: 10px;
    }
    .contact-info {
        font-size: 14px;
        color: #A9A9A9;
        text-align: center;
        padding: 0;
        margin: 0;
    }
  </style>
</head>
<body>
  <div class="logo">
      <h4 class="logo-label">Fine Collection Agency</h4>
  </div>
  </div>
    <div class="text">
      <p>Dear ${customerName},</p>
      <p>We are writing to inform you that you have an outstanding fine for speeding violation. This fine was incurred on ${fineDate} for the following reason:</p>
      <p>You were driving a ${vehicleBrand} ${vehicleModel} with license number ${vehicleLicenseNumber} on ${road} at ${timeOfDay} on ${violationDate} and exceeded the maximum speed by ${excessSpeed} km/h.</p>
      <#if fineAmount != -1>
        <p>The fine amount is EUR ${fineAmount}.</p>
        <p>Please pay this fine as soon as possible to avoid additional fees and legal action. You can pay online at our website or by visiting our office in The Hague.</p>
      <#else>
        <p>The fine amount has not yet been determined and will be decided by the prosecutor. A notice to appear in court will be sent shortly at your home address.</p>
      </#if>
      <p>Thank you for your cooperation.</p>
      <p>Sincerely,</p>
      <p>Fine Collection Agency</p>
    </div>
    <div class="end-bar">&nbsp;</div>
    <br>
    <p class="contact-info">Fine Collection Agency</p>
    <p class="contact-info">Phone: +31 123 456 789</p>
    <p class="contact-info">Address: Some Street 123, 2511 CD The Hague</p>
    <p class="contact-info">Email: fine@random-email.com</p>
    <p class="contact-info">fine.random-domain.com</p>
</body>
</html>
