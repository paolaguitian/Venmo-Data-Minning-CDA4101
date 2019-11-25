import response from './venmoResponse';

function getDataToArray(data = []) {
  return data.reduce((acc, payment) => {
    acc.push(payment.username, payment.message);
    return acc;
  },[])
}
console.olog
console.log(getDataToArray(response.data));