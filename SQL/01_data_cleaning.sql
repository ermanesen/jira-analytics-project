UPDATE customers
SET yearly_amount_spent = NULL
WHERE yearly_amount_spent < 0;

UPDATE customers
SET email = TRIM(email),
    address = TRIM(address),
    avatar = TRIM(avatar);
