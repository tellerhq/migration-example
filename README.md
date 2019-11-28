
# 💫 Migrate your app to Teller

This repo shows an example of how to run Teller and Plaid (or any other vendor) side-by-side. This is useful if you need institutions that Teller doesn't yet cover and another vendor does, or maybe you want us to earn your trust by only sending a subset of your traffic to Teller to begin with.

## 🤔 How does this work?

In this example we load Plaid's picker widget and hook into its public API. When the end-user selects an institution Plaid's SDK emits and event we can attach an event listener to that lets us decide whether to continue with default Plaid behaviour or do something else. 

In this example we dismiss Plaid's picker and load Teller's at the equivalent step. A simple setup looks like this:

```javascript
document.addEventListener("DOMContentLoaded", function() {

  // Initialise the Teller Connect SDK as usual. Note the extra property `skipPicker`. 
  // This lets us know you won't be displaying our picker or consent screens.
  // It's advised you set this otherwise the user may briefly see a flash of our 
  // consent screen when Teller intercepts the enrollment process
  
  var teller = TellerConnect.setup({
    skipPicker: true,
    applicationId: "#{ENV['TELLER_APP_ID']}",
    onEnrollment: function(enrollment) {
      // Handle a successful Teller enrollment
      document.location = document.location + "?provider=teller&token=" + enrollment.accessToken;
    },
  });

  // Initialise Plaid's SDK with a function for the `onEvent` property. 
  // Our implementation checks whether the selected institution is one
  // we want to handle. If it is we open the Teller picker with the 
  // institution pre-selected, and force dismiss Plaid's. If it isn't
  // it's a no-op.
  
  var plaid = Plaid.create({
    apiVersion: 'v2',
    clientName: 'Migrate to Teller',
    env: 'sandbox',
    product: 'transactions',
    key: "#{ENV['PLAID_PUBLIC_KEY']}",
    countryCodes: ['US'],
    onSuccess: function(public_token) {
      // Handle a successful Plaid enrollment
      document.location = document.location + "?provider=plaid&token=" + public_token;
    },
    onEvent: function(eventName, meta) {
      if(["BBVA - USA", "Bank of America", "Chase", "Capital One", "Citi", "TD Bank", "US Bank", "Wells Fargo"].indexOf(meta.institution_name) >= 0) {
        // Thank you very much. We can take it from here 😎
        teller.open({institution: meta.institution_name});
        plaid.exit({force: true})
      }
    }
  });

  document.getElementById("connect").addEventListener("click", function() {
    plaid.open();
  });
})
```

## 🖥 Development Setup

### Check out the repository

```bash
git clone git@github.com:tellerhq/migration-example.git && cd migration-example
```

### Install the dependencies

```
bundle install
```

### Configure the enviroment

This application requires two environment variables to be set: `TELLER_APP_ID`: your Teller Application ID, and `PLAID_PUBLIC_KEY`: your Plaid public key. You can set these any way you want, we use and recommend a `.env` file with [forego](https://github.com/ddollar/forego).
