# 한글 컴파일러 만들기

## 프로젝트 소개
한글로 작성한 프로그래밍 문법을 어셈블리어 파일로 만드는 컴파일러 입니다.

## 개발 기간
23.09.01 ~ 23.11.14

### 멤버
 - 조성민
 - 이민형
 - 김수진

## 문법
한글 컴파일러의 모든 문법은 C언어를 기준으로 합니다. 

### 사칙연산
 - '+' : "더하기"
 - '-' : "빼기"
 - '/' : "나누기"
 - '*' : "곱하기"
### 변수 값 할당
 - '=' : "는" 또는 "은"
### 조건문
 - if : "만약"
 - else : "아니면"
 - else if : "아니면만약"
### 반복문
 - while : "반복문"

## 예제 
```
시작

a 는 3 이다
b 는 3 이다

반복문 ( a 다르다 1 ){
  a 는 a 빼기 1 이다
  b 는 b 더하기 1 이다
}

끝
```
## 실행 방법
flex와 bison을 사용하였습니다.

flex, bison 참고 [https://heaeat.github.io/flex-bison/]

### 컴파일 실행 exe 파일 만들기
```
>>> bison -d min.y
>>> flex min.l // 
>>> gcc lex.yy.c min.tab.c -o [지정할 이름].exe
```
gcc 명령어를 입력하면 warning 메시지가 뜨는데 그대로 진행하셔도 됩니다.
### 컴파일 하기
```
>>> [지정한 이름].exe 예제코드.min
```
컴파일을 하면 a.s 파일이 생성됩니다.

### 참고자료
1) Stacksim이라는 자체적인 tool을 참고했습니다.
2) 아래 강의를 참고하였습니다.

컴파일러 구성론 [http://www.kocw.net/home/cview.do?cid=b0728df5b04aee67]
