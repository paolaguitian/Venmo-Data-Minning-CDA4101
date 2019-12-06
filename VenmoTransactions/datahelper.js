import response from './venmoResponse';

function getUsername(data = []) {
  return data.reduce((acc, payment) => {
    acc.push(payment.username);
    return acc;
  },[])
}

function getTransactions(data = []) {
  return data.reduce((acc,payment) => {
    acc.push(payment.message);
    return acc;
  },[])
}


const username = getUsername(response.data);
const transactions = getTransactions(response.data);
console.log(username);
console.log(transactions)

