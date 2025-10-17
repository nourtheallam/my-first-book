# Amortized Analysis


#### 1. What is it?

**Amortized:** paid-off over time. 

The time required to perform a sequence of data structures operations is averaged over all operations performed.

This guarantees the **average** performance of each operation in the **worst case** (meaning, we take the worst case performance of each operation and average the total). 

This is ==not the same== as **average case** analysis which relies on some probability distribution of the input while amortized always considers the worst case.

#### 2. Why amortized analysis?

- Can be used to show that the average cost of an operation is small, even though a single operation can be costly.
- Extra flexibility of amortized bounds can lead to more practical data structures.
	e.g. **balanced binary search tree** (usually, we need to rebalance the tree after insertion/deletion operations) vs. **splay tree**.

#### 3. Aggregate analysis

##### Steps
1. Show that for all $n$, a sequence of $n$ operations uses $T(n)$ worst-case time.
2. The amortized cost per operation is $\frac{T(n)}{n}$. 

Each operation has the same amortized cost. 

##### Example: Stack with multi-pop

**Problem:** $MULTIPOP(S, k)$ given the stack $S$, remove its $k$ top objects. 

**Pseudocode:**

While $k \neq 0$ and not $STACK-EMPTY(S)$
	do $POP(S)$
		$k \leftarrow k-1$

**Worst-case analysis:**
	PUSH, POP: $O(1)$
	MULTIPOP: $O(\min(k,s))$ given that the stack initially contains $s$ elements.

**Aggregate Analysis**

Analysis of a sequence of $n$ PUSH, POP, and MULTIPOP operations on an **initially empty** stack.

MULTIPOP: $O(n) \rightarrow$ the worst case of any operation is $O(n) \rightarrow$ the total cost of $n$ operations is $O(n^2)$. ==This is not tight!==

**Proper analysis:** 
	Observation: each object can be popped at most once for each time it is pushed.

The number of times POP can be called on an initially-empty stack, including calls within MULTIPOP, is at most the number of PUSH operations $\rightarrow$ which is $O(n)$. 

The total cost of $n$ PUSH, POP, MULTIPOP operations on an initially empty stack is $O(n)$. 

**Amortized cost per operation:** $\frac{O(n)}{n} = O(1)$. 

##### Example: Incrementing a Binary Counter 

**Problem:** A $k$-bit binary counter that counts upward from $0$. Stored in an array $A[0 \dots k-1]$. 

**Example:** Let $k=5$, array $=01011$. Incrementing this turns it into $01100$. 

**Procedure:**

==Shows us that the running time is proportional to the number of bit flips.==

INCREMENT($A[0 \dots k-1]$)
	i $\rightarrow$ 0
	While $i < k$ and $A[i] = 1$
		do 
			$A[i] \rightarrow 0$
			$i \rightarrow i+1$
	If $i < k$
		then $A[i] \rightarrow 1$

**Worst-case analysis:**
	INCREMENT: $O(k)$
	$n$ INCREMENTS: $O(kn)$

**Example:**

| Value | A[4] | A[3] | A[2] | A[1] | A[0] |
| ----- | ---- | ---- | ---- | ---- | ---- |
| 0     | 0    | 0    | 0    | 0    | 0    |
| 1     | 0    | 0    | 0    | 0    | 1    |
| 2     | 0    | 0    | 0    | 1    | 0    |
| 3     | 0    | 0    | 1    | 1    | 1    |
| 4     | 0    | 0    | 1    | 0    | 1    |
	**==Observation:==** $A[0]$ flips every time INCREMENT is called, $A[1]$ flips every other time, A[2], flips every third time, etc.
	$\rightarrow$ For $i=0, 1, \dots \lfloor \log n \rfloor$, bit $A[i]$ flips $\lfloor \frac{n}{2^i}\rfloor$ times in a sequence of $n$ INCREMENT operations on an initially $0$ counter. 
	$\rightarrow$ For $i > \lfloor \log n \rfloor$, bit $A[i]$ never flips. 

We can use the above observations to conclude that the total number of bit flips in the sequence of $n$ INCREMENT operations is $$\sum_{i=0}^{\lfloor \log n \rfloor} \left\lfloor \frac{n}{2^i} \right\rfloor < \sum_{i=0}^\infty \frac{n}{2^i} = n\sum_{i=0}^\infty \frac{1}{2^i} = 2n \quad \text{(Geometric series)}$$
**Worst-case analysis:** the worst-case time of a sequence of $n$ INCREMENT operations in thus $O(n)$. 

**Amortized cost per operation:** $\frac{O(n)}{n} = O(1)$. 

### 3. The accounting method

**Idea:** We pre-charge a cost for each operation, and we need to make sure that there is enough "credit" for each operation.

**Steps:**
1. We charge each operation what we think its amortized time =="cost"== is.
2. 
	1. If the amortized cost exceeds the actual cost, the surplus remains as a =="credit"== associated with the data structure. 
	2. If the amortized cost is less than the actual cost, the accumulated credit is used to pay for the cost overflow. 
	
	$\rightarrow$ To show that the amortized cost is correct, we should ensure that, at all times the total credit associated with the data structure is nonnegative $\iff$ the total amortized cost $\geq$ the total actual cost.
	
	==Why is this enough:== The credit is the difference between the total amortized cost so far, and the total actual cost so far. 

##### Example: Stack with MULTIPOP

Recall that
	**Actual cost:** PUSH is $O(1)$ ($1$ dollar), POP is $O(1)$ ($1$ dollar) and MULTIPOP is $O(\min(k, s))$ ($\min(k, s)$ dollars) where $s$ is the number of items in the stack. 

Suppose we assign the following **amortized costs**:
	PUSH $\rightarrow$ $2$ dollars
	POP $\rightarrow$ $0$ dollars
	MULTIPOP $\rightarrow$ $0$ dollars 
(resulting in $O(1)$ amortized time). 

We start with an empty stack, whose credit is $0$, which is fine because it is nonnegative. 

When we PUSH an object into the stack, we charge the operation $2$ dollars. Since this results in an excess cost of $1$, we charge $1$ dollar and use the other as credit. ==We associate this credit with the object we just pushed onto the stack.==

When we POP an object from the stack, we ==thus charge the operation nothing== as we pay its cost using its $1$ dollar credit. Since each object pushed onto the stack is associate with a credit, POP will never make the credit negative. 

And the same analysis applies for MULTIPOP$(k,s)$. There are $\min(k,s)$ dollars of credit associated with $\min(k,s)$ objects being popped. Therefore, the total credit of the stack is nonnegative at all times. 

##### Example: Incrementing a binary counter 

The running time of INCREMENT is proportional to the number of bits flipped, and the actual cost of bit flipping is $1$ dollar. 

Suppose we charge a bit flip of $0 \rightarrow 1$ an **amortized cost** of $2$ dollars and a bit flip of $1 \rightarrow 0$ a cost of $0$ dollars which we associate with the flipped bit. 

Therefore, when we flip $1$ to $0$, we charge $1$ dollar and give that bit $1$ dollar of credit. 

Since all the bits are initially $0$s, the total credit of the binary counter is initially $0$ and therefore nonnegative. Moreover, we can conclude that it is nonnegative at all times. 

INCREMENT changes at most one $0$ bit to $1$, so ==its amortized cost is at most== $2$, ==which results in $O(1)$!==

### 4. The Potential Method

**Idea:** Instead of credits, we present the prepaid work as ==potential== which can be ==released== to pay for future operations. 

**What's the difference between this and the credit system?** Potential is a ==function== of the entire data structure. 

**Steps**

- Let $D_{i}$ be our data structure after the $i$th operation and 
- Let $\phi(D_{i})$ be the potential of $D_{i}$ and 
- Let $C_{i}$ be the cost of the $i$th operation
- The amortized cost of the $i$th operation $a_{i} = C_{i} + \phi(D_{i}) - \phi(D_{i-1})$

$\rightarrow$ $\phi(D_{i}) - \phi(D_{i-1})$ is the change in potential

A correct potential function ensures that the total amortized cost is an upper bound on the total actual cost. 

The total amortized cost of $n$ operations is $$\sum_{i=1}^n a_{i} = \sum_{i=1}^n(C_{i} + \phi(D_{i}) - \phi(D_{i-1})) = (\sum_{i=1}^n C_{i}) + \phi(D_{n}) - \phi(D_{0})$$
==Our task now is to define a **potential function** such that==

1. $\phi(D_{0}) = 0$
2. $\phi(D_{i}) \geq 0$ for all $i$

If we achieve, we guarantee the upper bound
$$\sum_{i=1}^n C_{i} = \sum_{i=1}^n a_{i} - \phi(D_{n}) \leq \sum_{i=1}^n a_{i}$$
**Example: Stack with MULTIPOP**

We define the potential function $\phi$ on an initially empty stack to be the ==number of objects== in the stack. Therefore, $\phi(D_{0}) = 0$ where $D_{0}$ is the empty stack. This definition also ensures that the potential is always nonnegative as we can never have a negative number of objects in the stack. Moreover, the total amortized cost of $n$ operations with respect to $\phi$ represents an upper bound on the actual cost. 

If the stack contains $s$ objects before the $i$th operation, then PUSH leads to a positive change in potential of $1$
$$\phi(D_{i}) - \phi(D_{i-1}) = s + 1 - s = 1$$
And $$a_{i} = C_{i} +1$$
Similar logic applies if we do MULTIPOP with $k' = \min(k, s)$ elements, the change in potential would be $k'$ and the amortized cost of the $i$th operation is $C_{i} - k' = k'- k' = 0$.

<mark style="background: #FFB8EBA6;">$C_{i} = k'$ because the actual cost would be at most $k'$ elements popped by multipop. </mark>

And with pop, in that case the amortized cost would be $1 - 1 = 0$. 

**Example: Binary counter**

We let $\phi(D_{i})$ be the number of set bits (the number of $1$s). We define this quantity as $b_{i}$.

This potential function is correct because, initially, no bits are set and so $\phi(D_{0}) = 0$. Moreover, it can never be negative as you cannot have a negative number of set bits. 

The amortized cost of an INCREMENT operation will depend on the number of $1$s flipped to $0$s. Define this quantity for the $i$th increment as $t_{i}$. 

The actual cost of the operation is, therefore, at most $t_{i}+1$. 

If $b_{i}$ is $0$, then the $i$th operation sets all $k$ bits from $1$ to $0$. So, $b_{i-1} = t_{i} = k$. 

If $b_{i} > 0$, then $b_{i}= b_{i-1} - t_{i} + 1$. 

So, in either case, $b_{i} \leq b_{i-1} - t_{i} +1$, and the potential difference is 
$$ \begin{aligned} &= b_{i} - b_{i-1} \\ &\leq (b_{i} - t_{i} +1)- b_{i-1} \\ &= 1 - t_{i} \end{aligned} $$
And the amortized cost is therefore 
$$ \begin{aligned} a_{i} &= C_{i} + \phi(D_{i}) - \phi(D_{i-1}) \\ &\leq (t_{i}+1)+ (1-t_{i}) \\ &= 2 \\ &=O(1) \\ \end{aligned} $$

