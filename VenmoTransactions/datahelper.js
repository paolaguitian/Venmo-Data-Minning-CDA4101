import response from './venmoResponse';

function getDataToArray(data = []) {
  return data.reduce((acc, payment) => {
    acc.push(payment.username, payment.message);
    return acc;
  },[])
}
console.log(getDataToArray(response.data));
console.log(response.data.length)
