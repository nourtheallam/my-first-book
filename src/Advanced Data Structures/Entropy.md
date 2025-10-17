# 1. Entropy 

## 1. Definition 

Given a set of objects $S = \{ k_{1}, \dots, k_{n} \}$, a probability distribution for each object $D = \{ p_{1}, \dots , p_{n} \}$, the **entropy** $H(D)$ of $D$ is $$-\sum_{i=1}^np_{i} \cdot \log(p_{i}) = \sum_{i=1}^n p_{i} \cdot \log\left( \frac{1}{p_{i}} \right)$$
## 2. Shannon's Theorem 

Given a sender and a receiver, in which the sender want to send a sequence $S_{1}, \dots , S_{m}$ where each $S_{j}$ is chosen randomly and independently according to $D$, meaning that $S_{j} = k_{i}$ with probability $p_{i}$, **Shannon's theorem** states that for any protocol that the sender and the receiver might use, the expected number of bits required to transmit $S_{1}, \dots S_{m}$ using that protocol, which is at least $$m \cdot H(D)$$
## 3. Examples 

If we have a uniform distribution $p_{i} = \frac{1}{n}$, then $$H(D) = \sum_{i=1}^n \left( \frac{1}{n} \right) \log (n) = \log (n) \quad \text{(worst case)}$$If we have a geometric distribution $p_{i} = \frac{1}{2^i}$ for all $1 \leq i < n$, then 
$$H(D) = \sum_{i=1}^{n-1} \frac{i}{2^i} + \frac{n-1}{2^{n-1}}$$
This is an **arithmetico-geomtric** series. 


# 2. Entropy and data structure lower bounds

## 1. Theorem 1

For any comparison-based data structure storing $k_{1}, \dots , k_{n}$, each associated with probabilities $p_{1}, .., p_{n}$, the expected number of comparisons while searching for an item is $\Omega(H(D))$. 

**Proof**

Assume that the sender and receiver both store the elements $k_{1}, \dots , k_{n}$ in some comparison-based data structure that is agreed on beforehand. 

When the sender wants to transmit $S_{1}$, they perform the search for $S_{1}$ in the data structure. This results in a sequence of comparisons and the results of the comparisons form a sequence of $1$s (true) and $0$s (false) which the sender sends to the receiver. 

On the receiving end, the receiver runs a search algorithm without knowing the value of $S_{1}$. This can be done since the receiver is doing exactly the same comparisons and knows the results of the comparisons. This way, the sender can transmit a sequence to the receiver. 

Now, consider the number of bits needed to transmit this sequence and the number of comparisons needed to handle the request sequence, these numbers are the same. 

## 2. Static optimal BST

Assume that all the elements in the request sequence are in the tree, that $p_{i}$ is the probability of access of the element $A_{i}$, and that the entropy $H = \sum_{i=1}^n p_{i}  \cdot \log\left( \frac{1}{p_{i}} \right)$. 

The expected cost (number of comparisons), $C$, of the static optimal BST is $\geq H$. 

## 3. Not all requested elements are in the tree

Let $p_{i}$ be the probability of access of element $A_{i}$ and $q_{i}$ be the probability of requesting an element between $A_{i}$ and $A_{i+1}$. The entropy is defined as $$H = \sum_{i=1}^n p_{i} \cdot \log\left( \frac{1}{p_{i}} \right) + \sum_{i=0}^n q_{i} \cdot \log\left( \frac{1}{q_{i}} \right)$$
Note that $C \geq H$ still applies. 

![[Pasted image 20250313141919.png]]

# 3. Nearly-Optimal Search Trees

## 1. $p_{i}, H$

Our goal is to achieve $O(H+1)$ query time. 
#final what is the point of the $+1$?
Edge case of 1/log(n), etc.
## 2. Idea: Probability Splitting 

First, we find a key $k_{i}$ such that 
$$\sum_{j=1}^{i-1}p_{j} \leq \frac{1}{2} \sum_{j=1}^n p_{j}$$And
$$\sum_{j=i+1}^np_{j} \leq \frac{1}{2} \sum_{j=1}^n p_{j}$$

Let the key $k_{i}$ become the root of a binary search tree, then recurse. 

So, the left subtree is constructed recursively from $(k_{1}, \dots k_{i-1})$ with probabilities $(p_{1}, \dots , p_{i-1})$ and the right subtree is constructed recursively from $(k_{i+1}, \dots k_{n})$ with probabilities $(p_{i+1}, \dots , p_{n})$. 

Let $T$ be the resulting tree. 

**Observation:** In $T$, if node $k_{i}$ has depth $\text{depth}_T(k_{i})$, then 
$$\sum_{k_{j}\in T(k_{i})}p_{j} \leq \frac{1}{2^{\text{depth}_T(k_{i})}}$$
Where $T(k_{i})$ is the set of nodes in the subtree rooted at $k_{i}$. 

**Theorem:** $T$ can answer queries in $O(H + 1)$ expected time 
**Proof:** As $$p_{i} \leq \sum_{k_{j} \in T(k_{i})} p_{j} \leq \frac{1}{2^{\text{depth}_T(k_{i})}},$$
It must be true that
$$\text{depth}_T(k_{i}) \leq \log\left( \frac{1}{p_{i}} \right).$$
Thus, the expected depth of a chosen key is
$$\sum_{i=1}^n p_{i} \cdot \text{depth}_T(k_{i}) \leq \sum_{i=1}^n p_{i} \cdot \log\left( \frac{1}{p_i} \right) = H,$$
yielding a running time of $O(H+1)$. 

**Construction**

1. Finding $k_{i}$

This takes linear, $\Theta(n)$, time. 

2. $n$ keys 

$\Theta(n^2)$?

**Better algorithm**

1. Finding $k_{i}$

Use binary search instead, $\Theta(n \log n)$

***Best* Algorithm***

1. Finding $k_{i}$

Use doubling (exponential) search. 
- Check $k_{1}, k_{2}, k_{4}, k_{8}, \dots$ until we find the first $k_{2}^j$ with $2^j \geq i$
- Binary search in $k_{2}^{j-1}, \dots, k_{2}^j$

This gives us a running time of $\Theta(\log n)$. In fact, it is $\Theta(\log i)$ because $2^j \leq 2i$. 

Idea: search simultaneously starting at $k_{1}$ and working forward, and starting at $k_{n}$ and working backward. 

Then, $k_{i}$ can be found in $O{(\log(\min(i, n-i +1)))}$. 

And the total running time becomes $$T(n) = O(\log(\min (i, n-i +1))) + T(i-1) + T(n-i)$$Which we can prove, by induction that the running time is $O(n)$. 


# 4. MTF Compression

## 1. Elias gamma coding 

Used to code positive, and sometimes, negative integers whose maximum value is not known. There are $i \geq 0$ steps of encoding. 
1. Write down the binary expression of $i$, which uses $\log \lfloor i \rfloor + 1$ bits
2. Prepend it by $\lfloor \log i \rfloor$ $0$'s

    Example: $9 \rightarrow 0001001$


## 2. A coding scheme that uses fewer bits: 

- Gamma code: the leading $0$s encode $\lfloor \log i \rfloor \leq \log i$
- This number can be encoded using $2\lfloor \log \log i \rfloor + 1$ bits using Elias gamma coding 

    Example: $9 \rightarrow 0111001$

So, the number of bits used is $\log i + O(\log \log i)$. 


## 3. MTF Compression

Encode $m$ integers from $1$ to $m$. 

- The sender and receiver each maintain identical lists of $1, 2, \dots, n$ 
- To send the symbol $j$ we do not encode $j$ directly. Instead, the sender looks for $j$ in their list and finds it at position $i$. 
- Sender encodes $i$ in $\log i + O(\log \log i)$ bits and sends them to the receiver
- The receiver decodes $i$, and looks at the $i$th element in the list to find $j$
- Both move $j$ to the front and continue 

    Example: Given the range $1, 2$
        2211112
        21211122

**Jensen's inequality:** Let $f: R \rightarrow R$ be a strictly increasing concave function. Then, $\sum_{i=1}^n f(t_{i})$ subject to $\sum_{i=1}^nt_{i} \leq m$ is maximized when $t_{1} = t_{2} = \dots = t_{n} = \frac{m}{n}$. 

**Claim:** We can use this to prove that $\text{MTF}$ compresses $S_{1}, \dots S_{m}$ into $$n \log n + m\cdot H + O(n \log \log n + m \log H)$$ bits. 

**Proof:** If the number of distinct symbols between two consecutive occurrences of $j$ is $t-1$, then the cost of encoding the second $j$ is $\log(t) + O(\log \log t)$. Therefore, the total cost of encoding all the occurrences of $j$ is

- [ ] #final Where does the $n + O(n \log n)$ term come from? And how do the $t$s stay constant if we are employing MTF?
$$\begin{gathered}
C_{j} \leq \log n + O(\log \log n) + \sum_{i=1}^{m_{j}}(\log t_{i} + O(\log \log t_{i}))  \\ & \left( \sum_{j=1}t_{j} \leq m \right)\\
\leq \log n + O(\log \log n) + m_{j}\left( \log\left( \frac{m}{m_{j}} \right) + O\left( \log \log \frac{m}{m_{j}} \right) \right)
\end{gathered}$$
Where $t_{i} - 1$ is the number of symbols between the $i-1$ and $i$ occurrence of $j$. 

Summing over all $j$, the total number of bits used is 

$$\begin{aligned} 
&\sum_{j=1}^n C_{j}\\
&\leq n \log  n + O(n \log \log n) + m \cdot H + \sum_{j=1}^m O\left( m_{j} \log \log \frac{m}{m_{j}} \right) \\
& \leq n \log n + m \cdot H + O(n \log \log n + m \log H)
\end{aligned}$$

