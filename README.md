# 인터페이스
극단적으로 동일한 목적 하에 동일한 기능을 수행하게끔 강제하는 것이 바로 인터페이스의 역할이자 개념이다. 조금 더 유식하게 말하면, 자바의 다형성을 극대화하여 개발코드 수정을 줄이고 프로그램 유지보수성을 높이기 위해 인터페이스를 사용한다.
- 개발자 사이의 코드 규약을 정한다.
- 여러 구현체에서 공통적인 부분을 추상화한다.(다형성)

이건 개인적인 생각이지만 이런 인터페이스(규칙)을 정함으로서 이더리움의 ERC-20이 빠른속도로 발전할수 있는 가장 기본적인 기반이지 않았을까 생각한다.
즉 규칙을 정함으로써 엄청나게 많은 개선안(EIP) 들이 나오고 서로 쉽게 호환이 될수도 있었단 생각이 든다.
# 오버라이딩
Override는 '기각하다', '무시하다'의 뜻을 담고있다. 즉, '기존의 것을 무시하고 덮어쓰다.'의 의미를 가진다. 자바에서 메소드 오버라이딩이란, 상속의 관계에 있는 클래스 간에 하위 클래스가 상위 클래스와 '완전 동일한 메소드'를 덮어쓴다는 의미이다. 여기서 '완전 동일한 메소드'라는 말은 이름과 반환형이 같으면서 매개변수의 개수와 타입까지 모두 같은 메소드라는 의미이다. 즉, 오버로딩(overload)되지 않는 (JVM이 단순히 다른 메소드라고 구별을 할 수 없는) 메소드이다. 부모 클레스는 무시되고, 상속시킨 자식 클레스만 작동이 됨

즉 솔리디티 스마트 컨트랙트에서는 부모클레스의 기능을 자식클레스가 재정의해서 사용할수있다. 이때 재정의를 하려면 인터페이스를 규칙을 따라야한다.
- 메소드의 이름을 변경하면 안된다.
- 메소드의 매개변수의 갯수(arg1,arg2,...)와 데이터 타입(address,string,int...), 그리고 타입의 순서이다.
- 메소드의 리턴 타입 (솔리디티에서는 function () returns (타입)을 끝에 정의하는데 이걸 바꾸면 안된다.)

# 컨트랙트의 기본구조
pragma solidity + 버전정보

contract mycontract(컨트랙의 이름)

상태변수 : 클래스의 멤버변수라고 생각하면 될 것 같다.

생성자 생성 : constructor() public{ }

함수 : 자바와 자바스크립트를 섞은 느낌 (기능)



# Solidity 접근제어자 (가시성)
- private: 컨트랙트 내부에서만 접근이 가능하다.
- internal: 컨트랙트 내부 및 상속한 컨트랙트에서 접근이 가능하다. 그 외의 외부에서는 접근할 수 없다.
- public: 컨트랙트 내부 및 상속한 컨트랙트에서 접근할 수 있고, 외부에서도 접근이 가능하다.
- external: 외부에서만 접근이 가능하다.

# 함수타입제어자
view

 - 데이터를 읽을 수만 있다. read only - '데이터를 읽는다'는 것은 블록체인에서 읽어온다는 말

 - 가스비용 없음

pure

 - 데이터 읽지않음

 - 인자값만 활용해서 반환값 정함

 - 가스비용 없음

constant

 - 0.4.17이전에는 view/pure대신쓰였음 ( 현재는 안쓰는 제어자)

payable

 - 함수가 에더(eth)를 받을 수 있게함

 - 가스비용 있음

# 데이터타입 (값타입)
값타입

boolean - 모두 익숙한 불린타입입니다.

 - true/false

int - 모두 익숙한 정수타입입니다.

 - 정수

uint 
 - +,-,/ 등등 부호 금지
 - unsigned int (보통 양수만 사용하기 때문에 주로사용합니다.)

address

 - 20bytes 고정 이더리움 계정주소

 - 두개의 멤버소유 balance, transfer

bytes

 - 문자열저장(hex로 변환해서 저장해야함)

 - solidity는 string에 최적화 되어있지 않기 때문에 bytes로 사용

 - string 타입은 가스비용이 더 요구됨

 - bytes == bytes1 같은 의미라는 것

bytes/string

 - 크기 무한, 값타입은 아니고 참조형과 비슷

enum - 열거형입니다.

 - 열거형(문자열배열에 index를 부여한 자료형)

 - 값을 정수형으로 리턴

 - 이름{value1,value2}

 # 참조 타입
 참조타입 : 데이터위치를 말함

storage

 - 변수를 블록체인에 영구히 저장

 - 디폴트로 상태변수는 storage

memory

 - 임시저장변수(휘발성이라는 의미)

 - 디폴트로 매개변수와 리턴값은 memory

 - 배열은 strorage로 선언

# 참조타입 (배열)
참조타입 : 배열

 - 정적배열과 동적배열이 있음

 - 정적배열은 uint256[] memory a = new uint256[](5) 이런식으로 memory를 명시해야됨, 함수 밖에서는 상관없음

 # 참조타입 (구조체)
 참조타입 : 구조체

struct : 필요한 자료형들을 가지고 새롭게 정의하는 사용자 정의타입

struct Student{

string name;

string gender;

...

}

이런식으로 사용

# 참조타입 (매핑)
참조타입 : 매핑

 - Key&Value를 쌍으로 저장하는 것 dictionary타입과 유사함

 - mapping(_KeyType=>_ValueType) 이런식으로 사용

-----

# 다중 서명 계약(multisig)

만드는중~~ 